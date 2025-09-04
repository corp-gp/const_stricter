require "prism"

require "const_stricter/version"
require "const_stricter/railtie" if defined?(Rails::Railtie)

module ConstStricter
  autoload :ConstName,     "const_stricter/const_name"
  autoload :ConstParser,   "const_stricter/const_parser"
  autoload :ConstResolver, "const_stricter/const_resolver"

  module_function

  def constants_in_file(file_path:) = ConstParser.in_file(file_path:)
  def constants_in_code(code:)      = ConstParser.in_code(code:)

  def constant_missing?(namespace:, const_name:) = ConstResolver.missing?(namespace:, const_name:)
end
