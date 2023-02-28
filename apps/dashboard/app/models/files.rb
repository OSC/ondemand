# frozen_string_literal: true

# The parent class for Files (local or otherwise).
class Files
  # Guards MIME types by converting types into formats
  # that are usable for previewing content in the browser.
  #
  # @return [String] the converted MIME type.
  def self.mime_type_for_preview(type)
    # NOTE: use case statement here, not a hash so that we can
    # take advantage of the fact that Mime::Type in Ruby implements == to support multiple values
    # for example
    #
    #     x = Files.mime_type_by_extension('foo.yml')
    #     x === 'text/yaml'
    #     # => true
    #     x === 'application/x-yaml'
    #     # => true
    #

    # NOTE:  due to how most modern browsers are handling the yaml mime-types,
    # we have to cast the yaml mime-types to text/plain mime-type so we can
    # view the yaml files inline with the browser.
    # Would like to have a pattern match for the  yaml mime-types; something like application/*yml and application/*yaml
    # but couldn't find one that worked. Therefore, for now we're using full mime-type names for yaml mime-types.

    plain_cast_array = ['text/*', 'application/x-yml', 'application/x-yaml', 'application/yml', 'application/yaml']

    type = 'text/plain; charset=utf-8' if plain_cast_array.any? { |mime| /#{mime}/.match?(type) }

    type
  end

  # returns mime type string if found, "" otherwise
  def self.mime_type_by_extension(path)
    Mime::Type.lookup_by_extension(Pathname.new(path.to_s).extname.delete_prefix('.'))
  end
end
