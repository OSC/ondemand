require "pathname"

require "ood_portal_generator/version"
require "ood_portal_generator/application"
require "ood_portal_generator/view"

# The main namespace for ood_portal_generator
module OodPortalGenerator
  class << self
    # Root path of this library
    # @return [Pathname] root path of library
    def root
      Pathname.new(__dir__).dirname
    end

    def os_release_file
      path = '/etc/os-release'
      return nil unless File.exist?(path)
      path
    end

    def scl_apache?
      return true if os_release_file.nil?
      `source #{os_release_file} && [[ "$ID $ID_LIKE" = *"rhel"* ]] && [[ "$VERSION_ID" = "8"* ]]`
      ! $?.success?
    end
  end
end
