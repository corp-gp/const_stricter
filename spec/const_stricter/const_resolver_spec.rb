RSpec.describe ConstStricter do
  after(:each) do
    ConstStricter::ConstResolver.instance.instance_variable_set(:@evaluated, {})
  end

  it "resolve constant by name" do
    m =
      Module.new do
        class Item
          CATEGORY_ID = 1

          def category_id = CATEGORY_ID
        end
      end

    result = m.instance_eval { ConstStricter.evaluate(namespace: "Item", const_name: "CATEGORY_ID") }

    expect(result).to eq 1
  end

  it "resolve constant in parent context" do
    m =
      Module.new do
        module Catalog
          CATEGORY_ID = 2

          class Item
            def category_id = CATEGORY_ID
          end
        end
      end

    result = m.instance_eval { ConstStricter.evaluate(namespace: "Catalog::Item", const_name: "CATEGORY_ID") }

    expect(result).to eq 2
  end

  it "unable to resolve constant" do
    m =
      Module.new do
        class Item
          def group_id = GROUP_ID
        end
      end

    result = m.instance_eval { ConstStricter.evaluate(namespace: "Item", const_name: "GROUP_ID") }

    expect(result).to eq nil
  end
end
