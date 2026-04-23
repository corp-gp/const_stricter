require "singleton"

module ConstStricter
  class ConstResolver
    include Singleton

    def initialize
      @cache = {}
    end

    def self.missing?(namespace:, const_name:)
      evaluate(namespace:, const_name:).failure?
    end

    def self.evaluate(namespace:, const_name:)
      instance.evaluate(namespace:, const_name:)
    end

    def evaluate(namespace:, const_name:)
      lookup = ConstLookup.new
      lookup.cache = @cache

      lookup_result = lookup.find_constant(namespace:, const_name:, inherit: false)
      lookup_result = lookup.find_constant(namespace:, const_name:, inherit: true) if lookup_result.failure?

      lookup.resolved_paths.each do |const_hsh|
        @cache[const_hsh] = lookup_result
      end

      lookup_result
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

        evaluated_constant = (namespace ? Object.const_get(namespace) : Object).const_get(const_name, inherit)

        LookupResult.new(value: evaluated_constant)
      rescue NameError => e
        missing_name =
          if e.respond_to?(:missing_name)
            # activesupport/lib/active_support/core_ext/name_error.rb
            e.missing_name
          else
            e.message[/uninitialized constant (.+)$/, 1]
          end

        const_name_first_segment = ConstName.split(const_name).first

        if missing_name != const_name &&
           !const_name.start_with?(missing_name) &&
           missing_name.delete_prefix("#{namespace}::") != const_name &&
           missing_name != "#{namespace}::#{const_name_first_segment}"
          # срабатывание может быть вызвано не искомой константой,
          # а тем, что есть несвязанная ошибка в коде вызываемого класса/модуля
          return LookupResult.new.tap { |r| r.errors << e.message }
        end

        if namespace
          const_path = ConstName.new(ConstName.split(namespace))
          const_path.pop

          return find_constant(namespace: const_path.full_name, const_name:, inherit:)
        end

        LookupResult.new.tap { |r| r.errors << "unable to resolve #{const_name}" }
      end

      class LookupResult
        attr_reader :errors

        def initialize(value: nil)
          @value  = value
          @errors = []
        end

        def value!   = @value
        def success? = errors.empty?
        def failure? = !success?
      end
    end
  end
end
