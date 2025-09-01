RSpec.describe ConstStricter do
  describe "#find_constants_in_file" do
    it "parse file and find constants" do
      constants = described_class.constants_in_file(file_path: "spec/fixtures/product.rb")

      expect(constants.map(&:inspect)).to eq [
        "Object { Product } → spec/fixtures/product.rb:1",
        "Product { ApplicationRecord } → spec/fixtures/product.rb:1",
        "Product { Versioning } → spec/fixtures/product.rb:2",
        "Product { CATEGORY_ID } → spec/fixtures/product.rb:7",
        "Product { CATEGORY_ID } → spec/fixtures/product.rb:11",
      ]
    end
  end
end
