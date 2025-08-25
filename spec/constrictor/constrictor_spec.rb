RSpec.describe Constrictor do
  it "preserves namespace" do
    result = Constrictor.constants_in_code(code: <<~RUBY)
      module Catalog
        class Product
          def category_id = CATEGORY_ID
        end
      end
    RUBY

    expect(result).to include(const_name: "CATEGORY_ID", namespace: "Catalog::Product")
  end
end
