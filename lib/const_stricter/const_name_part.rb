module ConstStricter
  class ConstNamePart < String
    attr_accessor :dynamic, :line_no
  end
end
