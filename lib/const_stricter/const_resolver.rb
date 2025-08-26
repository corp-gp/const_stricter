require "singleton"

module ConstStricter
  class ConstResolver
    include Singleton

    def initialize
      @evaluated = {}
    end

    def self.evaluate(namespace:, const_name:, dynamic: false)
      instance.evaluate(namespace:, const_name:, dynamic:)
    end

    def evaluate(namespace:, const_name:, dynamic: false)
      return if dynamic

      resolved_paths = []

      constant =
        const_lookup_in_context(namespace, const_name, resolved_paths, inherit: false) ||
        const_lookup_in_context(namespace, const_name, resolved_paths, inherit: true)

      resolved_paths.each do |parsed_const_hsh|
        @evaluated[parsed_const_hsh] = constant
      end

      constant
    end

    private def const_lookup_in_context(current_namespace, const_name, resolved_paths, inherit:)
      cache_key = { namespace: current_namespace, const_name: }
      return @evaluated[cache_key] if @evaluated.key?(cache_key)

      resolved_paths << cache_key

      if current_namespace
        Object.const_get(current_namespace).const_get(const_name, inherit)
      else
        Object.const_get(const_name, inherit)
      end
    rescue NameError => e
      missed_const_name = e.message[/uninitialized constant (.+)$/, 1]
      if missed_const_name != const_name && !const_name.start_with?(missed_const_name) && !missed_const_name.delete_prefix(current_namespace) == const_name
        raise
      end

      if current_namespace
        const_lookup_in_context(current_namespace.split("::")[0..-2].join("::").presence, const_name, resolved_paths, inherit:)
      end
    end
  end
end
