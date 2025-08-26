namespace :constrictor do
  task lint: :environment do
    missed_constants = Set.new
    dynamic_constants = Set.new
    prev_found_const_count = 0

    const_resolver = Constrictor::ConstResolver.new

    loop do
      constants =
        Dir.glob("{app,lib}/**/*.rb").flat_map do |file_path|
          Constrictor.constants_in_file(file_path:)
        end
      break if constants.empty?

      found_const_names = Set.new
      constants.each do |parsed_const_hsh|
        if parsed_const_hsh[:dynamic]
          dynamic_constants << parsed_const_hsh
        elsif (constant = const_resolver.evaluate(**parsed_const_hsh))
          found_const_names << constant.full_name if constant.respond_to?(:full_name)
        else
          missed_constants << parsed_const_hsh
        end
      end
      break if prev_found_const_count == found_const_names.size

      prev_found_const_count = found_const_names.size
    end

    unless missed_constants.empty?
      pr "Dynamic constants"
      dynamic_constants.each do |parsed_const_hsh|
        puts "#{parsed_const_hsh[:namespace]} { #{parsed_const_hsh[:const_name]} }"
      end
      
      pr "Missed constants"
      missed_constants.each do |parsed_const_hsh|
        puts "#{parsed_const_hsh[:namespace]} { #{parsed_const_hsh[:const_name]} }"
      end
    end
  end
end
