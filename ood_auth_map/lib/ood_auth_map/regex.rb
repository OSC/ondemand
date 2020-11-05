require 'ood_auth_map'

class Regex < OodAuthMap
  # Default regular expression to use when parsing authenticated username
  DEFAULT_REGEX = "^(.+)$"

  # Body of option parser
  define_body do |parser|
    parser.separator ""
    parser.separator "Used to parse for a mapped authenticated user from a string using a regular expression."

    parser.separator ""
    parser.separator "General options:"

    options[:regex] = DEFAULT_REGEX
    parser.on("-r", "--regex=REGEX", "# Regular expression used to capture the system-level username", "# Default: #{DEFAULT_REGEX}") do |regex|
      options[:regex] = regex
    end
  end

  # Footer of option parser
  define_footer do |parser|
    parser.separator ""
    parser.separator <<-EOF.gsub(/^ {6}/, "")
      Examples:
          If the authenticated username completely matches the system-level
          username use the default regular expression:

              #{File.basename($0)} bob

          this will return `bob`.

          For more complicated strings, a regular expression needs to be
          supplied as an option:

              #{File.basename($0)} --regex='^(\\w+)@osc.edu$' bob@osc.edu

          where the first captured match is returned as the system-level username.

          If no match is found in the string, then a blank line is returned:

              #{File.basename($0)} --regex='^(\\w+)@osc.edu$' bob@mit.edu

          this will return a blank line, meaning no match was found.
    EOF
    parser.separator ""
  end

  # Find the user in the mapfile
  define_run do |auth_user|
    if sys_user = Helpers.parse_string(auth_user, /#{options[:regex]}/)
      puts sys_user
    else
      puts ""
      exit(false)
    end
  end
end