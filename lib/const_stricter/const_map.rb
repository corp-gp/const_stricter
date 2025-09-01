module ConstStricter
  class ConstMap < Hash
    def push(const_name:, namespace: [])
      if namespace.empty?
        self[const_name] = ConstMap.new
      else
        dig(*namespace)[const_name] = ConstMap.new
      end
    end
  end
end
