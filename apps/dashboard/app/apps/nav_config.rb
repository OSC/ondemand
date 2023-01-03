# frozen_string_literal: true

#
# Deprecated.
# This is now configurable through configuration. See UserConfiguration class.
class NavConfig

  class << self

    DEPRECATION_MSG = "NavConfig is deprecated and will be removed in 3.0. Use the ondemand.d property 'nav_categories' instead."
    DEFAULT_CATEGORIES = ['Apps', 'Files', 'Jobs', 'Clusters', 'Interactive Apps'].freeze
    DEFAULT_ALLOWLIST = false

    def categories
      ActiveSupport::Deprecation.warn(DEPRECATION_MSG) unless Rails.env.test?
      @categories || DEFAULT_CATEGORIES
    end

    def categories=(value)
      ActiveSupport::Deprecation.warn(DEPRECATION_MSG) unless Rails.env.test?
      @categories = value
    end

    def categories_allowlist
      ActiveSupport::Deprecation.warn(DEPRECATION_MSG) unless Rails.env.test?
      @categories_allowlist || DEFAULT_ALLOWLIST
    end

    def categories_allowlist=(value)
      ActiveSupport::Deprecation.warn(DEPRECATION_MSG) unless Rails.env.test?
      @categories_allowlist = value
    end

    alias categories_allowlist? categories_allowlist

    alias categories_whitelist categories_allowlist
    alias categories_whitelist= categories_allowlist=
    alias categories_whitelist? categories_allowlist?
  end
end
