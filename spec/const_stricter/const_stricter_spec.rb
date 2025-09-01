RSpec.describe ConstStricter do
  it "preserves namespace" do
    constants =
      described_class.constants_in_code(code: <<~RUBY)
        module Catalog
          class Product
            include Versioning

            def category_id = CATEGORY_ID
          end
        end
      RUBY

    expect(constants.map(&:inspect)).to include(
      "Catalog::Product { Versioning } → main:3",
      "Catalog::Product { CATEGORY_ID } → main:5",
    )
  end

  it "finds class name" do
    constant = described_class.constants_in_code(code: "class Product; end").first

    expect(constant.inspect).to eq("Object { Product } → main:1")
  end

  it "finds module name" do
    constant = described_class.constants_in_code(code: "module Product; end").first

    expect(constant.inspect).to eq("Object { Product } → main:1")
  end

  it "finds constant name" do
    constant = described_class.constants_in_code(code: "CATEGORY_ID").first

    expect(constant.inspect).to eq("Object { CATEGORY_ID } → main:1")
  end

  it "finds constant in global context" do
    constants =
      described_class.constants_in_code(code: <<~RUBY)
        module Catalog
          class Product
            include ::Versioning

            def category_id = ::CATEGORY_ID
          end
        end
      RUBY

    expect(constants.map(&:inspect)).to include(
      "Object { Versioning } → main:3",
      "Object { CATEGORY_ID } → main:5",
    )
  end
end
