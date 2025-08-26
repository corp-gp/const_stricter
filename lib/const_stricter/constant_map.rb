module ConstStricter
  class ConstantMap < Hash
    def push(namespace: [], const_name:)
      if namespace.empty?
        self[const_name] = ConstantMap.new
      else
        dig(*namespace)[const_name] = ConstantMap.new
      end
    end
  end
end