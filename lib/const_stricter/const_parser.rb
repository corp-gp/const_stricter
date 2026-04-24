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
      contexts = build_contexts(namespaces)

      constants = []

      const_map.each do |namespace, child_const_map|
        parsed_const =
          ParsedConst.new(
            const_name: namespace.full_name,
            contexts:,
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

    private def build_contexts(namespaces)
      current_namespace = nil

      contexts =
        namespaces.map do |ns|
          # ["SupplierSync::WebHooks::Jobs", "ReserveJob"] ->
          #   ["SupplierSync::WebHooks::Jobs", "SupplierSync::WebHooks::Jobs::ReserveJob"]
          context = ConstName.expand(ns, namespace: current_namespace)
          current_namespace = context
          context
        end

      contexts.reverse!
      contexts << ConstName::OBJECT
      contexts
    end
  end
end
