# frozen_string_literal: true

# Helper methods for RecentlyUsedApps widget
module RecentlyUsedAppsHelper
  # Returns the cached value for recently used apps
  def recently_used_apps
    Rails.cache.fetch('recently_used_apps', expires_in: 1.hour) do
      load_recently_used_apps
    rescue StandardError => e
      msg = "Cannot load recently used apps from '#{BatchConnect::Session.cache_root}' because of error #{e}"
      Rails.logger.info(msg)
      []
    end
  end

  private

  # Returns the 4 most recently used interactive applications based on their cache file
  # @return [Array<BatchConnect::App>] The 4 most recently used apps
  def load_recently_used_apps
    cache_files = BatchConnect::Session.cache_root.children.sort_by do |pathname|
                    File.mtime(pathname)
                  end.reverse.map do |pathname|
                    pathname.basename.to_s
                  end.slice(0, 4)
    sys_apps_index = {}
    # These apps variables are initialized in the ApplicationController class for all requests
    (@sys_apps + @dev_apps + @usr_apps).select(&:batch_connect_app?).each do |ood_app|
      ood_app.sub_app_list.each do |batch_connect_app|
        sys_apps_index[batch_connect_app.cache_file] = batch_connect_app if batch_connect_app.valid?
      end
    end

    cache_files.map do |file_path|
      next unless sys_apps_index.key?(file_path)

      matched_batch_connect_app = sys_apps_index.fetch(file_path)
      session_context = matched_batch_connect_app.build_session_context
      # Set cacheable to true to ensure update_session_with_cache sets the cached value
      session_context.each { |attribute| attribute.opts[:cacheable] = true }
      cache_file = BatchConnect::Session.cache_root.join(matched_batch_connect_app.cache_file)
      matched_batch_connect_app.tap { |app| app.update_session_with_cache(session_context, cache_file) }
    end.compact
  end
end
