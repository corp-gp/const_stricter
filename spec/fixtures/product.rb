class Product < ApplicationRecord
  include Versioning

  CATEGORY_ID = 1

  def scope_main_category
    where(category_id: CATEGORY_ID)
  end
end
