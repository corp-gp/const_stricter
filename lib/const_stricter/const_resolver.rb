require "singleton"

module ConstStricter
  class ConstResolver
    include Singleton

    def initialize
      @cache = {}
    end

    def self.missing?(const_name:, namespaces:)
      evaluate(const_name:, namespaces:).failure?
    end

    def self.evaluate(const_name:, namespaces:)
      instance.evaluate(const_name:, namespaces:)
    end

    def evaluate(const_name:, namespaces:)
      resolved_paths = Set.new

      result =
        find_in(namespaces, const_name, inherit: false) { |hsh| resolved_paths << hsh } ||
        find_in(namespaces, const_name, inherit: true) { |hsh| resolved_paths << hsh } ||
        LookupResult.failure("unable to resolve #{const_name}")

      resolved_paths.each { |key| @cache[key] = result }

      result
    end

    private def find_in(namespaces, const_name, inherit:)
      namespaces.detect do |namespace|
        break @cache[{ namespace:, const_name: }] if @cache.key?({ namespace:, const_name: })

        yield ({ namespace:, const_name: })

        lookup_result = try_constant(namespace, const_name, inherit:)
        break lookup_result if lookup_result
      end
    end

    private def try_constant(namespace, const_name, inherit:)
      value = (namespace ? Object.const_get(namespace) : Object).const_get(const_name, inherit)
      LookupResult.success(value)
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
        LookupResult.failure(e.message)
      end

      nil
    end

    class LookupResult
      attr_reader :errors

      def self.success(value)
        new(value:)
      end

      def self.failure(message)
        new(error: message)
      end

      def initialize(value: nil, error: nil)
        @value  = value
        @errors = error ? [error] : []
      end

      def value!   = @value
      def success? = errors.empty?
      def failure? = !success?
    end
  end
end
