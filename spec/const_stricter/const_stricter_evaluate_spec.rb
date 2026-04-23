RSpec.describe ConstStricter do
  after(:each) do
    ConstStricter::ConstResolver.instance.instance_variable_set(:@cache, {})
  end

  def parsed_const(namespace:, const_name:, lookup_namespaces: nil)
    ConstStricter::ParsedConst.new(namespace:, const_name:).tap do |pc|
      pc.lookup_namespaces = lookup_namespaces if lookup_namespaces
    end
  end

  # Regression: compound inherited constant (e.g. `class Foo < Outer::Base`) inside a deep
  # namespace used to raise instead of bubbling up the scope chain, because missing_name
  # was "Deep::Ns::Outer" which didn't match any of the original guard conditions.
  it "resolves compound inherited constant in deep namespace" do
    module Outer
      class Base; end
    end

    module Deep
      module Ns
        class Foo < Outer::Base; end
      end
    end

    result = ConstStricter::ConstResolver.evaluate(parsed_const(namespace: "Deep::Ns::Foo", const_name: "Outer::Base"))

    expect(result.value!).to eq Outer::Base
  ensure
    Object.send(:remove_const, :Deep) if Object.const_defined?(:Deep) # rubocop:disable RSpec/RemoveConst
    Object.send(:remove_const, :Outer) if Object.const_defined?(:Outer) # rubocop:disable RSpec/RemoveConst
  end

  it "resolves constant by name" do
    m =
      Module.new do
        class Item
          CATEGORY_ID = 1

          def category_id = CATEGORY_ID
        end
      end

    pc = parsed_const(namespace: "Item", const_name: "CATEGORY_ID")
    result = m.instance_eval { ConstStricter::ConstResolver.evaluate(pc) }

    expect(result).to be_success
    expect(result.value!).to eq(1)
  end

  it "resolves constant in parent context" do
    m =
      Module.new do
        module Catalog
          CATEGORY_ID = 2

          class Item
            def category_id = CATEGORY_ID
          end
        end
      end

    pc = parsed_const(namespace: "Catalog::Item", const_name: "CATEGORY_ID")
    result = m.instance_eval { ConstStricter::ConstResolver.evaluate(pc) }

    expect(result).to be_success
  end

  # Regression: compact module notation (module A::B::C) contributes only one lexical
  # nesting level, so the resolver must not bubble up past A::B::C into A::B or A.
  it "does not resolve constant through compact module boundary" do
    module SupplierSync
      module WebHooks
        module Mtforce
          module Reserve; end
        end

        module Jobs
          class ReserveJob; end
        end
      end
    end

    result = ConstStricter::ConstResolver.evaluate(
      parsed_const(
        namespace:         "SupplierSync::WebHooks::Jobs::ReserveJob",
        const_name:        "Mtforce::Reserve",
        lookup_namespaces: ["SupplierSync::WebHooks::Jobs::ReserveJob", "SupplierSync::WebHooks::Jobs", nil],
      ),
    )

    expect(result).to be_failure
  ensure
    Object.send(:remove_const, :SupplierSync) if Object.const_defined?(:SupplierSync) # rubocop:disable RSpec/RemoveConst
  end

  it "resolves constant through individually opened module boundaries" do
    module Abc
      module Def
        Foo = Class.new
        class Bar; end
      end
    end

    result = ConstStricter::ConstResolver.evaluate(
      parsed_const(
        namespace:         "Abc::Def::Bar",
        const_name:        "Foo",
        lookup_namespaces: ["Abc::Def::Bar", "Abc::Def", "Abc", nil],
      ),
    )

    expect(result).to be_success
  ensure
    Object.send(:remove_const, :Abc) if Object.const_defined?(:Abc) # rubocop:disable RSpec/RemoveConst
  end

  it "does not resolve constant past compact module boundary into grandparent" do
    module Outer2
      Foo2 = Class.new
      module Inner2
        module Deep2
          class Work2; end
        end
      end
    end

    # Simulates `module Outer2::Inner2::Deep2; class Work2` opened at the top level
    # (without first opening Outer2 individually). Outer2::Foo2 is not visible.
    result = ConstStricter::ConstResolver.evaluate(
      parsed_const(
        namespace:         "Outer2::Inner2::Deep2::Work2",
        const_name:        "Foo2",
        lookup_namespaces: ["Outer2::Inner2::Deep2::Work2", "Outer2::Inner2::Deep2", nil],
      ),
    )

    expect(result).to be_failure
  ensure
    Object.send(:remove_const, :Outer2) if Object.const_defined?(:Outer2) # rubocop:disable RSpec/RemoveConst
  end

  it "unable to resolve constant" do
    m =
      Module.new do
        class Item
          def group_id = GROUP_ID
        end
      end

    pc = parsed_const(namespace: "Item", const_name: "GROUP_ID")
    result = m.instance_eval { ConstStricter::ConstResolver.evaluate(pc) }

    expect(result).to be_failure
  end
end
