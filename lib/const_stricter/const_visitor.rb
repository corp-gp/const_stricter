require "const_stricter/const_name"
require "const_stricter/const_name_part"
require "const_stricter/const_map"

module ConstStricter
  class ConstVisitor < Prism::Visitor
    attr_reader :const_map

    instance_methods.grep(/visit_/).each do |method_name|
      define_method(method_name) { |node| visit_child_nodes(node) }
    end

    def initialize
      @const_path = []
      @current_const = ConstName.new
      @const_map = ConstMap.new
    end

    def visit_constant_path_node(node)
      if node.compact_child_nodes.empty?
        # include ::ComponentViewPath не вызывает visit_constant_read_node
        visit_constant_read_node(node, force_global_scope: true)
      else
        @current_const.unshift(
          ConstNamePart.new(node.name.to_s).tap do |name_part|
            name_part.line_no = node.location.start_line
          end,
        )
        visit_child_nodes(node)
      end
    end

    EMPTY_ARRAY = [].freeze
    private_constant :EMPTY_ARRAY

    def visit_constant_read_node(node, force_global_scope: false)
      @current_const.unshift(
        ConstNamePart.new(node.name.to_s).tap do |name_part|
          name_part.line_no = node.location.start_line
        end,
      )
      @const_map.push(const_path: force_global_scope ? EMPTY_ARRAY : @const_path, const_name: @current_const)
      @current_const = ConstName.new
    end

    def visit_child_nodes(node)
      if !@current_const.empty? && !node.is_a?(Prism::ConstantPathNode)
        unless @current_const.parent.dynamic
          # slice возвращает код ноды, включая все дочерние
          # в родительскую цепочку добавляется только самый верхний уровень
          # connection.module::Jobs::ImportProductsJob
          @current_const.unshift(
            ConstNamePart.new(node.slice).tap do |name_part|
              name_part.line_no = node.location.start_line
              name_part.dynamic = true
            end,
          )
        end
        if node.compact_child_nodes.empty?
          # Values()::USER_ID
          @const_map.push(const_path: @const_path, const_name: @current_const)
          @current_const = ConstName.new
        end
      end
      super
    end
  end
end
