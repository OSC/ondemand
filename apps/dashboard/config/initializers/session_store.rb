# Be sure to restart your server when you modify this file.

if Rails.application.config.session_store.nil?
  begin
    user = Etc.getpwuid
    dir = "/var/tmp/#{user.name}"
    Dir.mkdir(dir, 0o0700) unless Dir.exist?(dir)

    stat = File.stat(dir)
    correctly_owned = stat.uid == user.uid && stat.gid == user.gid && stat.mode == 0o040700

    raise(StandardError, "#{dir} does not have correct ownership #{user.uid}:#{user.gid} #{stat.mode}") unless correctly_owned

    Rails.application.config.session_store(:cache_store, cache: ActiveSupport::Cache::FileStore.new(dir))
  rescue StandardError => e
    warn "Cannot use cache store because of error: #{e.message}"
    Rails.application.config.session_store(:cookie_store, key: '_dashboard_session', secure: Rails.env.production?, same_site: :strict)
  end
end
