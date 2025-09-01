RSpec.describe ConstStricter do
  it "find dynamic const name" do
    constants =
      described_class.constants_in_code(code: <<~RUBY)
        class Product
          def price = user_rate_module::PRICE_COEF * base_price
          def price = const_get(user_rate_module_name)::PRICE_COEF * base_price
          def price = RateModule()::PRICE_COEF * base_discount

          def self.RateModule = user_rate_module
        end
      RUBY

    expect(constants.map(&:inspect)).to include(
      "Product { user_rate_module::PRICE_COEF } → main:2",
      "Product { const_get(user_rate_module_name)::PRICE_COEF } → main:3",
      "Product { RateModule()::PRICE_COEF } → main:4",
    )
  end

  it "can't find extrapolated const name" do
    constants =
      described_class.constants_in_code(code: <<~RUBY)
        class Product
          def price = "PRICE_COEF".constantize * base_price
        end
      RUBY

    expect(constants.map(&:inspect)).to eq(["Object { Product } → main:1"])
  end
end
