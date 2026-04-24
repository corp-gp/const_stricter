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

    private def find_constants_recursive(const_map, namespaces: [], segments: [])
      # namespaces одинаков для всех констант на этом уровне — вычисляем один раз
      lookup_namespaces = build_lookup_namespaces(namespaces, segments)

      constants = []

      const_map.each do |namespace, child_const_map|
        parsed_const =
          ParsedConst.new(
            namespaces: lookup_namespaces,
            const_name: namespace.full_name,
          )
        parsed_const.location = [file_path, namespace.line_no].compact.join(LINE_NO_SEPARATOR)
        parsed_const.dynamic  = namespace.dynamic

        constants << parsed_const

        unless child_const_map.empty?
          child_segments = segments + ConstName.split(namespace.full_name)
          constants.concat find_constants_recursive(child_const_map, namespaces: namespaces + [namespace], segments: child_segments)
        end
      end

      constants
    end

    # Each module/class opening contributes one lexical nesting level regardless of
    # how many :: segments its name has, so valid lookup namespaces are only at those
    # boundaries (innermost first, nil = Object).
    private def build_lookup_namespaces(namespaces, segments)
      stops =
        namespaces.reverse.each_with_object([segments.length]) do |ns, acc|
          acc << (acc.last - ConstName.split(ns.full_name).length)
        end
      stops.map { |n| n == 0 ? "Object" : segments.first(n).join("::") }
    end
  end
end
