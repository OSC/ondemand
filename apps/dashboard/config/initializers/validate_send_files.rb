Rails.application.config.after_initialize do
  module ActionDispatch
    class Response
      class FileBody

        # Stream the file's contents if Rack::Sendfile isn't present,
        # which it isn't for FilesController#fs.
        def each
          File.open(to_path, "rb") do |file|
            real_path = File.readlink("/proc/self/fd/#{file.fileno}")
            return '' unless AllowlistPolicy.default.permitted?(real_path)

            while chunk = file.read(16_384)
              yield chunk
            end
          end
        end
      end
    end
  end
end
