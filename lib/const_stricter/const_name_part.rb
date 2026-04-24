module ConstStricter
  class ConstNamePart < String
    attr_accessor :dynamic, :line_no

    def self.wrap(value, line_no:, dynamic: false)
      ConstNamePart.new(value).tap do |s|
        s.line_no = line_no
        s.dynamic = dynamic
      end
    end
  end
end
