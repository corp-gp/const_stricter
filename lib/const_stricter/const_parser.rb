require "const_stricter/scoped_const_visitor"
require "const_stricter/parsed_const"

module ConstStricter
  class ConstParser
    attr_reader :file_path

    def initialize(prism_code, file_path:)
      @prism_code = prism_code
      @file_path  = file_path
    end

    def self.in_file(file_path:)
      new(parse_file(file_path), file_path:).find_constants
    end

    private_class_method def self.parse_file(file_path) = Prism.parse_lex_file(file_path)

    PATH_TO_MAIN = "main"
    private_constant :PATH_TO_MAIN

    def self.in_code(code:)
      new(parse_code(code), file_path: PATH_TO_MAIN).find_constants
    end

    private_class_method def self.parse_code(code) = Prism.parse_lex(code)

    def find_constants
      visitor = ScopedConstVisitor.new
      @prism_code.value[0].accept(visitor)

      find_constants_recursive(visitor.const_map)
    end

    LINE_NO_SEPARATOR = ":"
    private_constant :LINE_NO_SEPARATOR

    private def find_constants_recursive(const_map, namespaces: [])
      constants = []

      const_map.each do |namespace, child_const_map|
        parsed_const =
          ParsedConst.new(
            namespace:  ConstName.new(namespaces.map(&:full_name)).full_name,
            const_name: namespace.full_name,
          )
        parsed_const.location = [file_path, namespace.line_no].compact.join(LINE_NO_SEPARATOR)
        parsed_const.dynamic  = namespace.dynamic

        constants << parsed_const

        unless child_const_map.empty?
          constants.concat find_constants_recursive(child_const_map, namespaces: namespaces + [namespace])
        end
      end

      constants
    end
  end
end
