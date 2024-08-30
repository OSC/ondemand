class OodAuthMap
  # Module that provides many useful helper methods that can be reused in the
  # varying CLIs
  module Helpers
    class << self
      # Parse a grid-mapfile for a given authenticated user name
      # The mapfile must follow rules here: http://toolkit.globus.org/toolkit/docs/2.4/gsi/grid-mapfile_v11.html
      # @param file [String] file name
      # @param auth_user [String] authenticated username
      # @return [String, nil] mapped user name or {nil} if no match
      def parse_mapfile(file, auth_user)
        parse_file(file, %r[^"#{Regexp.quote auth_user}" ([\w\.-@]+)$])
      end

      # Parse a file using a given regular expression pattern and output the
      # first captured match
      # @param file [String] file name
      # @param regex [Regexp] regular expression pattern
      # @return [String, nil] captured string or {nil} if no match
      def parse_file(file, regex)
        File.foreach(file) do |line|
          if match = parse_string(line, regex)
            return match
          end
        end
        nil
      end

      # Parse a string with a given regular expression pattern and output the
      # first captured match
      # @param str [String] string to match
      # @param regex [Regexp] regular expression pattern
      # @return [String, nil] captured string or {nil} if no match
      def parse_string(str, regex)
        regex.match(str)
        $1
      end
    end
  end
end
