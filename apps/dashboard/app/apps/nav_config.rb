# frozen_string_literal: true

#
# Deprecated.
# This is now configurable through configuration. See UserConfiguration class.
class NavConfig
  class << self
    attr_accessor :categories, :categories_allowlist
    alias categories_allowlist? categories_allowlist

    alias categories_whitelist categories_allowlist
    alias categories_whitelist= categories_allowlist=
    alias categories_whitelist? categories_allowlist?
  end

  self.categories = ['Apps', 'Files', 'Jobs', 'Clusters', 'Interactive Apps']
  self.categories_allowlist = false
end
