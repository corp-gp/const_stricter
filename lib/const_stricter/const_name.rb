module ConstStricter
  class ConstName
    attr_reader :dynamic, :name_parts
    private :name_parts

    def initialize(name_parts = [])
      @name_parts = name_parts
      @dynamic = false
    end

    def inspect = "#{full_name} :#{line_no}"

    def line_no
      @line_no ||= name_parts[0].line_no
    end

    def parent = name_parts[0]

    def unshift(name_part)
      @dynamic ||= name_part.dynamic
      name_parts.unshift name_part
    end

    def pop = name_parts.pop

    MODULE_DELIMITER = "::"
    private_constant :MODULE_DELIMITER

    def self.split(string)
      string.split(MODULE_DELIMITER)
    end

    def full_name
      name_parts.join(MODULE_DELIMITER) unless empty?
    end

    def empty? = name_parts.empty?
  end
end
