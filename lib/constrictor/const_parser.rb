require "active_support/core_ext/module/redefine_method"

require "constrictor/const_name"
require "constrictor/const_name_part"
require "constrictor/constant_map"

module Constrictor
  class ConstParser < Prism::Visitor
    attr_reader :const_map

    instance_methods.grep(/visit_/).each do |method_name|
      redefine_method(method_name) { |node| visit_child_nodes(node) }
    end

    def initialize
      @namespace = []
      @current_const = ConstName.new
      @const_map = ConstantMap.new
    end

    def visit_constant_path_node(node)
      if node.compact_child_nodes.empty?
        # include ::ComponentViewPath не вызывает visit_constant_read_node
        visit_constant_read_node(node, force_global_namespace: true)
      else
        @current_const.add_parent ConstNamePart.new(node.name.to_s)
        visit_child_nodes(node)
      end
    end

    EMPTY_ARRAY = [].freeze

    def visit_constant_read_node(node, force_global_namespace: false)
      @current_const.add_parent ConstNamePart.new(node.name.to_s)
      @const_map.push(namespace: force_global_namespace ? EMPTY_ARRAY : @namespace, const_name: @current_const)
      @current_const = ConstName.new
    end

    def visit_child_nodes(node)
      if @current_const.any? && !node.is_a?(Prism::ConstantPathNode)
        unless @current_const.parent.dynamic
          # slice возвращает код ноды, включая все дочерние
          # в родительскую цепочку добавляется только самый верхний уровень
          # connection.module::Jobs::ImportProductsJob
          @current_const.add_parent ConstNamePart.new(node.slice).tap { |name_part| name_part.dynamic = true }
        end
        if node.compact_child_nodes.empty?
          # Values()::USER_ID
          @const_map.push(namespace: @namespace, const_name: @current_const)
          @current_const = ConstName.new
        end
      end
      super
    end
  end
end