class User
  include Traceable

  ADMIN_ID = 1
  TRACEABLE_TYPE = "RetailUser"

  def admin?
    id == ADMIN_ID
  end

  def gravatar
    HTTP.get("https://gravatar.com/#{permalink}")
  end

  def github
    HTTP.get("https://github.com/#{permalink}")
  end
end
