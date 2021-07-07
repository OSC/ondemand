class UserPreferences
    require 'yaml'
  
    def initialize()
        FileUtils.mkdir_p("~/.config/ondemand/") unless File.exists?("~/.config/ondemand/")
        @preferences ||= begin
            if preferences_file.file? && preferences_file.readable?
                YAML.safe_load(preferences_file.read)
            else
                {}
            end
        rescue => e
            puts "#{e.message}"
            @preferences = {}
        end
    end

    attr_accessor :preferences
  
    def preferences_file
        @preferences_file ||= begin
            file = ENV['OOD_PREFERENCES_FILE'] || "#{User.new.dir}/.config/ondemand/preferences.yml"
            Pathname.new(file.to_s).expand_path
        end
    end
  
    def method_missing(method_name, *args, &block)
        method_string = method_name.to_s
        if @preferences.key?(method_string)
            @preferences.dig(method_string, *args)
        else
            super
        end
    end

    def write_setting(settings_hash)
        settings_hash.each do |key, value|
            @preferences[key] = value
        end
        
        begin
            File.open(@preferences_file, "w") { |file| file.write(@preferences.to_yaml) }
        rescue => e
            puts "Failed to write to preferences file: #{e.message}"
        end

    end
end