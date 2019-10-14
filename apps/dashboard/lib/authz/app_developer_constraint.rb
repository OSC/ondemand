module Authz
  class AppDeveloperConstraint
    def self.matches?(request)
      Configuration.app_development_enabled?
    end
  end
end
