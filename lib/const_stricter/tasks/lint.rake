require "colorized_string"

namespace :const_stricter do
  desc "Lint constants in project const_stricter:lint[{app,lib}/**/*.rb]"
  task :lint, [:glob] => :environment do |_t, args|
    glob = args[:glob] || "{app,lib}/**/*.rb"

    missed_constants  = Hash.new { |hsh, key| hsh[key] = Set.new }
    dynamic_constants = Hash.new { |hsh, key| hsh[key] = Set.new }

    prev_found_const_count = 0

    loop do
      constants =
        Dir.glob(glob).flat_map do |file_path|
          ConstStricter.constants_in_file(file_path:)
        end
      break if constants.empty?

      found_const_names = []
      constants.each do |parsed_const|
        if parsed_const.dynamic
          dynamic_constants[parsed_const] << parsed_const.location
        elsif (constant = ConstStricter.evaluate(**parsed_const.to_h))
          found_const_names << constant.full_name if constant.respond_to?(:full_name)
        else
          missed_constants[parsed_const] << parsed_const.location
        end
      end
      break if prev_found_const_count == found_const_names.size

      prev_found_const_count = found_const_names.size
    end

    unless dynamic_constants.empty?
      puts ColorizedString["Dynamic constants"].colorize(:light_blue)
      dynamic_constants.each_key.with_index do |parsed_const, idx|
        pretty_print(parsed_const, locations: dynamic_constants[parsed_const], number: idx + 1)
      end
    end

    unless missed_constants.empty?
      puts ColorizedString["Missed constants"].colorize(:yellow)
      missed_constants.each_key.with_index do |parsed_const, idx|
        pretty_print(parsed_const, locations: missed_constants[parsed_const], number: idx + 1)
      end
    end
  end
end

LOCATION_SEPARATOR = "\n  ↳ "

def pretty_print(parsed_const, locations:, number:)
  puts <<~TEXT
    #{number}. #{parsed_const.namespace} { #{ColorizedString[parsed_const.const_name].colorize(:light_magenta)} }#{LOCATION_SEPARATOR}#{locations.join(LOCATION_SEPARATOR)}
  TEXT
end
