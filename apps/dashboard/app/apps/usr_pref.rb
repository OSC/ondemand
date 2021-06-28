require 'yaml'

class UserPref
    def initialize(user_dir)
        @user_pref_file = user_dir + "/preferences.yml"
        @user_paths = populate_paths
    end

    attr_reader :user_paths

    private def parse_yaml
        @preferences = YAML.load_file(@user_pref_file)
    end

    private def populate_paths
        parse_yaml
        fav_paths = []
        @preferences["paths"].each |path| do
            fav_paths << path
        end

        fav_paths
    end
end
