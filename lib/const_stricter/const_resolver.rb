require "singleton"

module ConstStricter
  class ConstResolver
    include Singleton

    def initialize
      @cache = {}
    end

    def self.missing?(parsed_const)
      evaluate(parsed_const).failure?
    end

    def self.evaluate(parsed_const)
      instance.evaluate(parsed_const)
    end

    def evaluate(parsed_const)
      resolved_paths = []

      result =
        find_in(parsed_const.lookup_namespaces, parsed_const.const_name, inherit: false) { |hsh| resolved_paths << hsh } ||
        find_in(parsed_const.lookup_namespaces, parsed_const.const_name, inherit: true) { |hsh| resolved_paths << hsh } ||
        LookupResult.failure("unable to resolve #{parsed_const.const_name}")

      resolved_paths.each { |key| @cache[key] = result }

      result
    end

    private def find_in(lookup_namespaces, const_name, inherit:)
      lookup_namespaces.each do |namespace|
        yield ({ namespace:, const_name: })

        return @cache[{ namespace:, const_name: }] if @cache.key?({ namespace:, const_name: })

        result = try_constant(namespace, const_name, inherit:)
        return result if result.success? || result.unrelated_error?
      end

      nil
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
        return LookupResult.failure(e.message, unrelated: true)
      end

      LookupResult.failure("unable to resolve #{const_name}")
    end

    class LookupResult
      attr_reader :errors

      def self.success(value)
        new(value:)
      end

      def self.failure(message, unrelated: false)
        new(error: message, unrelated_error: unrelated)
      end

      def initialize(value: nil, error: nil, unrelated_error: false)
        @value           = value
        @errors          = error ? [error] : []
        @unrelated_error = unrelated_error
      end

      def value!           = @value
      def success?         = errors.empty?
      def failure?         = !success?
      def unrelated_error? = @unrelated_error
    end
  end
end
