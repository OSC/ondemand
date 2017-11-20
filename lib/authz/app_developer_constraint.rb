module Authz
  class AppDeveloperConstraint
    def self.matches?(request)
      AppConfig.app_development_enabled?
    end
  end
end
