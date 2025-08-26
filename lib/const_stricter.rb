require "prism"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/object/blank"

require "const_stricter/version"
require "const_stricter/railtie" if defined?(Rails::Railtie)

module ConstStricter
  autoload :ConstFinder, "const_stricter/const_finder"
  autoload :ConstResolver, "const_stricter/const_resolver"

  module_function

  def constants_in_file(file_path:) = ConstFinder.in_file(file_path:)
  def constants_in_code(code:) = ConstFinder.in_code(code:)

  def evaluate(...) = ConstResolver.evaluate(...)
end
