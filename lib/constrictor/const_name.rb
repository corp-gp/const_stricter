module Constrictor
  class ConstName
    attr_reader :dynamic, :name_parts
    private :name_parts

    def initialize
      @name_parts = []
      @dynamic = false
    end

    def parent = name_parts[0]

    def add_parent(name_part)
      @dynamic ||= name_part.dynamic
      name_parts.unshift name_part
    end

    MODULE_DELIMITER = "::"

    def full_name = any? ? name_parts.join(MODULE_DELIMITER) : nil

    def any? = !name_parts.empty?
  end
end