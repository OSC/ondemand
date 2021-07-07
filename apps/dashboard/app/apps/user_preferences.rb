class UserPreferences
    require 'yaml'
  
    def initialize()
      _prefs
    end
  
    def preferences_file
        @preferences_file ||= begin
            file = ENV['OOD_PREFERENCES_FILE'] || "#{User.new.dir}/preferences.yml"
            Pathname.new(file.to_s).expand_path
        end
    end
    
    private def _prefs
        @_prefs ||= begin
            if preferences_file.file? && preferences_file.readable?
                YAML.safe_load(preferences_file.read)
            else
                {}
            end
        rescue => e
            puts "#{e.message}"
            @_prefs = {}
        end
    end
  
    def method_missing(method_name, *args, &block)
        method_string = method_name.to_s
        if @_prefs.key?(method_string)
            @_prefs.dig(method_string, *args)
        else
            super
        end
    end

    def write_setting(app_name, settings_hash)
        settings_hash.each do |key, value|
            @_prefs[app_name][key] = value
        end
        File.open(@preferences_file, "w") { |file| file.write(@_prefs.to_yaml) }
    end
end