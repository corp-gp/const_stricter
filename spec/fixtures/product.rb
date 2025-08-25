class Product < Array
  CATEGORY_ID = 1

  def scope_main_category
    filter { _1.category_id == CATEGORY_ID }
  end
end