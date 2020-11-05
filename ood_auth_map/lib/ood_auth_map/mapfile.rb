require 'ood_auth_map'

class Mapfile < OodAuthMap
  # Default mapfile to use when parsing file
  DEFAULT_MAPFILE = "/etc/grid-security/grid-mapfile"

  # Body of option parser
  define_body do |parser|
    parser.separator ""
    parser.separator "Used to scan a grid-mapfile for a mapped authenticated user."

    parser.separator ""
    parser.separator "General options:"

    options[:file] = DEFAULT_MAPFILE
    parser.on("-f", "--file=FILE", "# File to scan for matches", "# Default: #{DEFAULT_MAPFILE}") do |file|
      options[:file] = file
    end
  end

  # Footer of option parser
  define_footer do |parser|
    parser.separator ""
    parser.separator <<-EOF.gsub(/^ {6}/, "")
      Examples:
          To scan the default grid-mapfile using a url-encoded authenticated
          username:

              #{File.basename($0)} http%3A%2F%2Fcilogon.org%2FserverA%2Fusers%2F58606%40cilogon.org

          this will return an empty string if no matches are found.

          To scan a custom grid-mapfile using authenticated username:

              #{File.basename($0)} --file=/path/to/mapfile http://cilogon.org/serverA/users/53756@cilogon.org

          this file must follow the rules for grid-mapfile's listed at
          http://toolkit.globus.org/toolkit/docs/2.4/gsi/grid-mapfile_v11.html
    EOF
    parser.separator ""
  end

  # Find the user in the mapfile
  define_run do |auth_user|
    if sys_user = Helpers.parse_mapfile(options[:file], auth_user)
      puts sys_user
    else
      puts ""
      exit(false)
    end
  end
end