json.path @path.to_s
json.url files_path(@filesystem, @path).to_s
#TODO: support array of shell urls, along with the default shell url which could be above
json.shell_url OodAppkit.shell.url(path: @path.to_s).to_s
json.files_path files_path(@filesystem, '/')
json.files_upload_path url_for(fs: @filesystem, action: 'upload') if Configuration.upload_enabled?
json.filesystem @filesystem

json.files @files do |f|
  json.id f[:id]
  json.type f[:directory] ? 'd' : 'f'
  json.name f[:name]

  json.url files_path(@filesystem, @path.join(f[:name]).to_s) if f[:downloadable]
  json.download_url files_path(@filesystem, @path.join(f[:name]).to_s, download: '1') if f[:downloadable]
  json.edit_url OodAppkit.editor.edit(path: @path.join(f[:name]).to_s, fs: @filesystem).to_s

  json.size f[:size]
  json.human_size f[:human_size]
  json.modified_at f[:date]
  json.owner f[:owner]
  json.mode f[:mode]
end
json.breadcrumbs_html render partial: 'breadcrumb', formats: [:html, :erb], collection: @path.descend, as: :file, locals: { file_count: @path.descend.count, full_path: @path }
json.path_selector_breadcrumbs_html render partial: 'path_selector_breadcrumb', formats: [:html, :erb], collection: @path.descend, as: :file, locals: { file_count: @path.descend.count, full_path: @path }
json.shell_dropdown_html render partial: 'shell_dropdown', formats: [:html, :erb]
json.time Time.now.to_i
json.error_message alert if alert
