module ConstStricter
  class ParsedConst
    attr_reader   :namespaces, :const_name
    attr_accessor :dynamic, :location

    def context = namespaces.first

    DEFAULT_NAMESPACE = "Object"
    private_constant :DEFAULT_NAMESPACE

    def initialize(namespaces:, const_name:)
      @namespaces = namespaces
      @const_name = const_name
    end

    def inspect = "#{context} { #{const_name} } → #{location}"
  end
end
