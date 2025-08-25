RSpec.describe Constrictor do
  it "find dynamic const name" do
    result = Constrictor.constants_in_code(code: <<~RUBY)
      class Product
        def price = user_rate_module::PRICE_COEF * base_price
        def price = const_get(user_rate_module_name)::PRICE_COEF * base_price
        def price = RateModule()::PRICE_COEF * base_discount

        def self.RateModule = user_rate_module
      end
    RUBY

    expect(result).to include(
      { const_name: "user_rate_module::PRICE_COEF", dynamic: true, namespace: "Product" },
      { const_name: "const_get(user_rate_module_name)::PRICE_COEF", dynamic: true, namespace: "Product" },
      { const_name: "RateModule()::PRICE_COEF", dynamic: true, namespace: "Product" },
    )
  end

  it "can't find extrapolated const name" do
    result = Constrictor.constants_in_code(code: <<~RUBY)
      class Product
        def price = "PRICE_COEF".constantize * base_price
      end
    RUBY

    expect(result).to be_empty
  end
end
