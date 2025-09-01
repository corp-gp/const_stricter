require "const_stricter/const_visitor"

module ConstStricter
  class ScopedConstVisitor < ConstVisitor
    def visit_module_node(node)
      visit_scoped_node(node)
    end

    def visit_class_node(node)
      visit_scoped_node(node)
    end

    def visit_scoped_node(node)
      const_name_visitor = ConstVisitor.new
      node.constant_path.accept(const_name_visitor)

      const_name = const_name_visitor.const_map.keys[0]

      @const_map.push(const_path: @const_path, const_name:)

      @const_path << const_name

      # первый дочерний элемент - это название модуля/класса (constant_path)
      node.compact_child_nodes[1..].each do |child_node|
        child_node.accept(self)
      end

      @const_path.pop if const_name
    end
  end
end
