require "prism"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/object/blank"

require "constrictor/version"
require "constrictor/railtie" if defined?(Rails::Railtie)

module Constrictor
  autoload :ConstFinder, "constrictor/const_finder"
  autoload :ConstResolver, "constrictor/const_resolver"

  module_function

  def constants_in_file(file_path:) = ConstFinder.in_file(file_path:)
  def constants_in_code(code:) = ConstFinder.in_code(code:)

  def evaluate(...) = ConstResolver.evaluate(...)
end
