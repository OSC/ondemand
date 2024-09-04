# frozen_string_literal: true

# module PathSanitizer
# A simple module to sanitize a path using the same
# algorithm that ActiveStorage::Filename#sanitized uses.
module PathSanitizer
  # Sanitize a path. Uses the same algorithm as ActiveStorage::Filename#sanitized
  def sanitized_path(path)
    replaced = path.to_s.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '�')
    replaced = replaced.strip.tr("\u{202E}%$|:;/\t\r\n\\", '-')
    Pathname.new(replaced)
  end
end
