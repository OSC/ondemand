# frozen_string_literal: true

# Simple Module to read a path that can be a URI
# or a file.
module UriReader
  def read_uri(path)
    uri = URI.parse(path.to_s)
    if uri.scheme == 'http' || uri.scheme == 'https'
      Net::HTTP.get(uri)
    else
      File.read(path.to_s)
    end
  end
end
