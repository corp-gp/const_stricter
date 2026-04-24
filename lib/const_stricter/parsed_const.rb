module ConstStricter
  class ParsedConst
    attr_reader   :contexts, :const_name
    attr_accessor :dynamic, :location

    def context = contexts.first

    def initialize(contexts:, const_name:)
      @contexts   = contexts
      @const_name = const_name
    end

    def inspect = "#<#{self.class.name} #{self}>"
    def to_s    = "#{context} { #{const_name} } → #{location}"
  end
end
