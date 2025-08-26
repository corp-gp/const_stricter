RSpec.describe ConstStricter do
  it "preserves namespace" do
    result = described_class.constants_in_code(code: <<~RUBY)
      module Catalog
        class Product
          include Versioning

          def category_id = CATEGORY_ID
        end
      end
    RUBY

    expect(result).to include(
      { const_name: "CATEGORY_ID", namespace: "Catalog::Product" },
      { const_name: "Versioning", namespace: "Catalog::Product" },
    )
  end

  it "find constant in global context" do
    result = described_class.constants_in_code(code: <<~RUBY)
      class Product
        include ::Versioning

        def category_id = ::CATEGORY_ID
      end
    RUBY

    expect(result).to include(
      { const_name: "CATEGORY_ID", namespace: nil },
      { const_name: "Versioning", namespace: nil },
    )
  end
end
