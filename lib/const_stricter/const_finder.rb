require "const_stricter/scoped_const_parser"
require "const_stricter/parsed_const"

module ConstStricter
  class ConstFinder
    attr_reader :file_path, :parser

    def initialize(prism_code, file_path:)
      @file_path = file_path

      @parser = ScopedConstParser.new
      prism_code.value[0].accept(@parser)
    end

    def self.in_file(file_path:)
      new(parse_file(file_path), file_path:).find_constants
    end

    PATH_TO_MAIN = "main"
    private_constant :PATH_TO_MAIN

    def self.in_code(code:)
      new(parse_code(code), file_path: PATH_TO_MAIN).find_constants
    end

    def find_constants
      find_const_recursive(parser.const_map)
    end

    private_class_method def self.parse_file(file_path) = Prism.parse_lex_file(file_path)
    private_class_method def self.parse_code(code) = Prism.parse_lex(code)

    private def find_const_recursive(const_map, parent_namespace: [])
      constants = []

      const_map.each do |namespace, child_const_map|
        parsed_const =
          ParsedConst.new(
            namespace:  parent_namespace.map(&:full_name).join("::").presence,
            const_name: namespace.full_name,
          )
        parsed_const.location = [file_path, namespace.line_no].compact.join(":")
        parsed_const.dynamic  = namespace.dynamic

        constants << parsed_const

        unless child_const_map.empty?
          constants.concat find_const_recursive(child_const_map, parent_namespace: parent_namespace + Array.wrap(namespace))
        end
      end

      constants
    end
  end
end
