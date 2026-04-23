module ConstStricter
  ConstNamePart =
    Struct.new(:value, :line_no, :dynamic) do
      def to_s = value
    end
end
