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

    def scl_apache?
      `[ -f /etc/os-release ] && source /etc/os-release && [[ "$ID $ID_LIKE" = *"rhel"* ]] && [[ "$VERSION_ID" = "8"* ]]`
      ! $?.success?
    end
  end
end
