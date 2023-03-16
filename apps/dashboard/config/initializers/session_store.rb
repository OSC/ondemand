# Be sure to restart your server when you modify this file.

if Rails.application.config.session_store.nil?
  begin
    dir = "/var/tmp/#{Etc.getpwuid.name}"
    Dir.mkdir(dir, 0o0700) unless Dir.exist?(dir)

    Rails.application.config.session_store(:cache_store, cache: ActiveSupport::Cache::FileStore.new(dir))
  rescue StandardError => e
    warn "Cannot use cache store because of error: #{e.message}"
    Rails.application.config.session_store(:cookie_store, key: '_dashboard_session', secure: Rails.env.production?, same_site: :strict)
  end
end
