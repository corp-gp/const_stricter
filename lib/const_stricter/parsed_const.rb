module ConstStricter
  class ParsedConst
    attr_reader   :namespace, :const_name
    attr_accessor :dynamic, :location
    attr_writer   :lookup_namespaces

    def lookup_namespaces
      @lookup_namespaces ||=
        begin
          parts = ConstName.split(namespace)
          parts.length.downto(0).map { |n| n == 0 ? nil : parts.first(n).join("::") }
        end
    end

    DEFAULT_NAMESPACE = "Object"
    private_constant :DEFAULT_NAMESPACE

    def initialize(namespace:, const_name:)
      @namespace  = namespace || DEFAULT_NAMESPACE
      @const_name = const_name
    end

    def inspect = "#{namespace} { #{const_name} } → #{location}"
  end
end
