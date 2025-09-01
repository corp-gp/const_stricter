module Traceable
  def self.included(base)
    @traceable = base
  end

  def save_changes
    HTTP.post("https://tracer.com/", body: { changes: changes.to_json, traceable_type: @traceable::TRACEABLE_TYPE })
  end
end
