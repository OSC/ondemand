require 'securerandom'

module NginxStage
  # A class to handle generating storing and retrieving per user secret key base
  class SecretKeyBaseFile
    # Path of the secret base key file
    # @return [String] the path of the secret file
    attr_reader :path

    # Secret base key string
    # @return [String, nil] the 128 char secret base key, or nil if file doesn't exist
    def secret
      @secret ||= File.read(path) if File.file?(path) && File.readable?(path)
    end

    # Generate new secret and store in file
    # @return [String] the secret generated
    def generate
      @secret = SecureRandom.hex(64)

      # FIXME: this now generates the PUN config directory if it doesn't exist
      # instead of Generator#template => Generator#create_file => Generator#empty_directory
      FileUtils.mkdir_p File.dirname(path), mode: 0755

      File.write path, @secret, 0, perm: 0600

      @secret
    end

    # @return [Boolean] whether or not the file exists
    def exist?
      File.file?(path)
    end

    # @param user [String] the user we want to get the secret for
    def initialize(user)
      @path = NginxStage.pun_secret_key_base_path(user: user)
    end
  end
end
