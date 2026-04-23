require "singleton"

module ConstStricter
  class ConstResolver
    include Singleton

    def initialize
      @cache = {}
    end

    def self.missing?(namespace:, const_name:)
      evaluate(namespace:, const_name:).equal?(nil)
    end

    def self.evaluate(namespace:, const_name:)
      instance.evaluate(namespace:, const_name:)
    end

    def evaluate(namespace:, const_name:)
      lookup = ConstLookup.new
      lookup.cache = @cache

      evaluated_constant =
        lookup.find_constant(namespace:, const_name:, inherit: false) ||
        lookup.find_constant(namespace:, const_name:, inherit: true)

      lookup.resolved_paths.each do |const_hsh|
        @cache[const_hsh] = evaluated_constant
      end

      evaluated_constant
    end

    class ConstLookup
      attr_accessor :cache, :resolved_paths

      def initialize
        @resolved_paths = []
      end

      def find_constant(namespace:, const_name:, inherit: false)
        cache_key = { namespace:, const_name: }
        return @cache[cache_key] if @cache.key?(cache_key)

        resolved_paths << cache_key

        (namespace ? Object.const_get(namespace) : Object).const_get(const_name, inherit)
      rescue NameError => e
        missing_name =
          if e.respond_to?(:missing_name)
            # activesupport/lib/active_support/core_ext/name_error.rb
            e.missing_name
          else
            e.message[/uninitialized constant (.+)$/, 1]
          end

        const_name_first_segment = const_name.split("::").first

        if missing_name != const_name &&
           !const_name.start_with?(missing_name) &&
           missing_name.delete_prefix("#{namespace}::") != const_name &&
           missing_name != "#{namespace}::#{const_name_first_segment}"
          # срабатывание может быть вызвано не искомой константой,
          # а тем, что есть несвязанная ошибка в коде вызываемого класса/модуля
          raise
        end

        if namespace
          const_path = ConstName.new(ConstName.split(namespace))
          const_path.pop

          find_constant(namespace: const_path.full_name, const_name:, inherit:)
        end
      end
    end
  end
end
