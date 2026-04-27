RSpec.describe ConstStricter do
  around(:each) do |example|
    example.run
    raise ArgumentError, "should be called in isolated context" unless @isolated
  end

  def isolated(&)
    @isolated = true
    fork(&)
  end

  # Regression: compound inherited constant (e.g. `class Foo < Outer::Base`) inside a deep
  # namespace used to raise instead of bubbling up the scope chain, because missing_name
  # was "Deep::Ns::Outer" which didn't match any of the original guard conditions.
  it "resolves compound inherited constant in deep namespace" do
    isolated do
      module Outer
        class Base; end
      end

      module Deep
        module Ns
          class Foo < Outer::Base; end
        end
      end

      result =
        ConstStricter::ConstResolver.evaluate(
          const_name: "Outer::Base",
          contexts:   %w[Deep::Ns::Foo Object],
        )

      expect(result.value!).to eq Outer::Base
    end
  end

  it "resolves constant by name" do
    isolated do
      class Item
        CATEGORY_ID = 1

        def category_id = CATEGORY_ID
      end

      result =
        ConstStricter::ConstResolver.evaluate(
          const_name: "CATEGORY_ID",
          contexts:   %w[Item Object],
        )
      expect(result).to be_success
      expect(result.value!).to eq(1)
    end
  end

  it "resolves constant in parent context" do
    isolated do
      module Catalog
        CATEGORY_ID = 2

        class Item
          def category_id = CATEGORY_ID
        end
      end

      result =
        ConstStricter::ConstResolver.evaluate(
          const_name: "CATEGORY_ID",
          contexts:   %w[Catalog::Item Catalog Object],
        )
      expect(result).to be_success
    end
  end

  # Regression: compact module notation (module A::B::C) contributes only one lexical
  # nesting level, so the resolver must not bubble up past A::B::C into A::B or A.
  it "does not resolve constant through compact module boundary" do
    isolated do
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

      result =
        ConstStricter::ConstResolver.evaluate(
          const_name: "Mtforce::Reserve",
          contexts:   %w[SupplierSync::WebHooks::Jobs::ReserveJob SupplierSync::WebHooks::Jobs Object],
        )
      expect(result).to be_failure
    end
  end

  it "resolves constant through individually opened module boundaries" do
    isolated do
      module Abc
        module Def
          Foo = Class.new
          class Bar; end
        end
      end

      result =
        ConstStricter::ConstResolver.evaluate(
          const_name: "Foo",
          contexts:   %w[Abc::Def::Bar Abc::Def Abc Object],
        )
      expect(result).to be_success
    end
  end

  it "does not resolve constant past compact module boundary into grandparent" do
    isolated do
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
      result =
        ConstStricter::ConstResolver.evaluate(
          const_name: "Foo2",
          contexts:   %w[Outer2::Inner2::Deep2::Work2 Outer2::Inner2::Deep2 Object],
        )
      expect(result).to be_failure
    end
  end

  it "unable to resolve constant" do
    isolated do
      class Item
        def group_id = GROUP_ID
      end

      result =
        ConstStricter::ConstResolver.evaluate(
          const_name: "GROUP_ID",
          contexts:   %w[Item Object],
        )
      expect(result).to be_failure
    end
  end
end
