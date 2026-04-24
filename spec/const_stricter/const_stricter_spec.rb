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

    expect(constants.map(&:to_s)).to include(
      "Catalog::Product { Versioning } → main:3",
      "Catalog::Product { CATEGORY_ID } → main:5",
    )
  end

  it "finds class name" do
    constant = described_class.constants_in_code(code: "class Product; end").first

    expect(constant.to_s).to eq("Object { Product } → main:1")
  end

  it "finds module name" do
    constant = described_class.constants_in_code(code: "module Product; end").first

    expect(constant.to_s).to eq("Object { Product } → main:1")
  end

  it "finds constant name" do
    constant = described_class.constants_in_code(code: "CATEGORY_ID").first

    expect(constant.to_s).to eq("Object { CATEGORY_ID } → main:1")
  end

  it "sets contexts reflecting compact module notation" do
    constants =
      described_class.constants_in_code(code: <<~RUBY)
        module SupplierSync::WebHooks::Jobs
          class ReserveJob
            def call
              Mtforce::Reserve
            end
          end
        end
      RUBY

    mtforce_ref = constants.find { |c| c.const_name == "Mtforce::Reserve" }
    expect(mtforce_ref).not_to be_nil
    expect(mtforce_ref.contexts).to eq(%w[SupplierSync::WebHooks::Jobs::ReserveJob SupplierSync::WebHooks::Jobs Object])
  end

  it "sets contexts reflecting individually opened modules" do
    constants =
      described_class.constants_in_code(code: <<~RUBY)
        module A
          module B
            class C
              Foo::Bar
            end
          end
        end
      RUBY

    foo_ref = constants.find { |c| c.const_name == "Foo::Bar" }
    expect(foo_ref).not_to be_nil
    expect(foo_ref.contexts).to eq(%w[A::B::C A::B A Object])
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

    expect(constants.map(&:to_s)).to include(
      "Object { Versioning } → main:3",
      "Object { CATEGORY_ID } → main:5",
    )
  end
end
