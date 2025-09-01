module ConstStricter
  ParsedConst = Struct.new(:namespace, :const_name, keyword_init: true)

  class ParsedConst
    attr_accessor :dynamic, :location

    DEFAULT_NAMESPACE = "Object"
    private_constant :DEFAULT_NAMESPACE

    def initialize(namespace:, const_name:)
      super

      self.namespace ||= DEFAULT_NAMESPACE
    end

    def inspect = "#{namespace} { #{const_name} } → #{location}"
  end
end
