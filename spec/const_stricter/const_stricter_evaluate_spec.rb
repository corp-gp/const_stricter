RSpec.describe ConstStricter do
  after(:each) do
    ConstStricter::ConstResolver.instance.instance_variable_set(:@evaluated, {})
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

    result = ConstStricter::ConstResolver.evaluate(namespace: "Deep::Ns::Foo", const_name: "Outer::Base")

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

    result = m.instance_eval { ConstStricter::ConstResolver.evaluate(namespace: "Item", const_name: "CATEGORY_ID") }

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

    result = m.instance_eval { ConstStricter::ConstResolver.evaluate(namespace: "Catalog::Item", const_name: "CATEGORY_ID") }

    expect(result).to be_success
  end

  it "unable to resolve constant" do
    m =
      Module.new do
        class Item
          def group_id = GROUP_ID
        end
      end

    result = m.instance_eval { ConstStricter::ConstResolver.evaluate(namespace: "Item", const_name: "GROUP_ID") }

    expect(result).to be_failure
  end
end
