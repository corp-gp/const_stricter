RSpec.describe Constrictor do
  describe "#find_constants_in_file" do
    it "parse file and find constants" do
      result = Constrictor.constants_in_file(file_path: "spec/fixtures/product.rb")

      expect(result).to eq [
        { const_name: "Product", namespace: nil },
        { const_name: "ApplicationRecord", namespace: "Product" },
        { const_name: "Versioning", namespace: "Product"},
        { const_name: "CATEGORY_ID", namespace: "Product"},
      ]
    end
  end
end
