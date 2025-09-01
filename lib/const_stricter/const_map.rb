module ConstStricter
  class ConstMap < Hash
    def push(const_name:, const_path: [])
      if const_path.empty?
        self[const_name] = ConstMap.new
      else
        dig(*const_path)[const_name] = ConstMap.new
      end
    end
  end
end
