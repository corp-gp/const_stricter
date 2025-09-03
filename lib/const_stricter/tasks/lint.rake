require "colorized_string"

namespace :const_stricter do
  desc "Lint constants in project const_stricter:lint[{app,lib}/**/*.rb]"
  task :lint, [:glob] => :environment do |_t, args|
    glob = args[:glob] || "{app,lib}/**/*.rb"

    file_paths = Dir.glob(glob)

    constants =
      file_paths.flat_map do |file_path|
        ConstStricter.constants_in_file(file_path:)
      end

    missed_constants  = Hash.new { |hsh, key| hsh[key] = Set.new }
    dynamic_constants = Hash.new { |hsh, key| hsh[key] = Set.new }

    constants.each do |parsed_const|
      if parsed_const.dynamic
        dynamic_constants[parsed_const] << parsed_const.location
      elsif !ConstStricter.constant_missed?(namespace: parsed_const.namespace, const_name: parsed_const.const_name)
        missed_constants[parsed_const] << parsed_const.location
      end
    end

    unless dynamic_constants.empty?
      puts ColorizedString["Dynamic constants"].light_blue
      dynamic_constants.each_key.with_index do |parsed_const, idx|
        pretty_print(parsed_const, locations: dynamic_constants[parsed_const], number: idx + 1)
      end
    end

    unless missed_constants.empty?
      puts ColorizedString["Missed constants"].yellow
      missed_constants.each_key.with_index do |parsed_const, idx|
        pretty_print(parsed_const, locations: missed_constants[parsed_const], number: idx + 1)
      end
    end

    if dynamic_constants.empty? && missed_constants.empty?
      puts "No problems found"
    end

    puts ColorizedString["#{file_paths.size} files scanned"].green
  end
end

LOCATION_SEPARATOR = "\n  ↳ "

def pretty_print(parsed_const, locations:, number:)
  puts <<~TEXT
    #{number}. #{ColorizedString[parsed_const.const_name].light_magenta} in #{parsed_const.namespace}
      ↳ #{locations.join(LOCATION_SEPARATOR)}
  TEXT
end
