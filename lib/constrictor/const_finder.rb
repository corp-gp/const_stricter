require "constrictor/scoped_const_parser"

module Constrictor
  class ConstFinder
    def initialize(prism_code)
      @parser = ScopedConstParser.new
      prism_code.value[0].accept(@parser)
    end

    def self.in_file(file_path:)
      new(parse_file(file_path)).find_constants
    end

    def self.in_code(code:)
      new(parse_code(code)).find_constants
    end

    def find_constants
      find_const_recursive(@parser.const_map).uniq
    end

    private_class_method def self.parse_file(file_path) = Prism.parse_lex_file(file_path)
    private_class_method def self.parse_code(code) = Prism.parse_lex(code)

    private def find_const_recursive(const_map, parent_namespace: [])
      constants = []
      const_map.each do |namespace, child_const_map|
        full_namespace = parent_namespace + Array.wrap(namespace)
        child_const_map.each_key do |const_name|
          parsed_const_hsh = {
            namespace:  full_namespace.map(&:full_name).join("::"),
            const_name: const_name.full_name,
          }
          parsed_const_hsh[:dynamic] = true if const_name.dynamic
          constants << parsed_const_hsh
        end
        constants += find_const_recursive(child_const_map, parent_namespace: full_namespace) unless child_const_map.empty?
      end
      constants
    end
  end
end