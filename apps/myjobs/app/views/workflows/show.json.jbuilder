json.extract! @workflow, :pbsid, :name, :batch_host, :script_path, :staged_script_name, :staged_dir, :created_at, :updated_at, :status, :account, :job_array_request
json.extract! @workflow, :xdmod_url if @workflow.xdmod_url_available?
json.set! 'status_label', status_label(@workflow)
json.set! 'active', @workflow.active?
json.set! 'fs_root', Filesystem.new.fs(@workflow.staged_dir)
json.set! 'host_title', cluster_title(@workflow.batch_host)
json.folder_contents (@workflow.folder_contents).each do |file|
  json.set! 'path', file.path
  json.set! 'relative_path', file.relative_path
  json.set! 'name', Pathname(file.path).basename.to_s
  json.set! 'type', Pathname(file.path).file? ? 'file' : 'dir'
  json.set! 'fsurl', Filesystem.new.fs(file.path)
  json.set! 'fs_base', Filesystem.new.fs(File.dirname(file.path))
  if @workflow.batch_host
    hostname = OODClusters[@workflow.batch_host].login.host if OODClusters[@workflow.batch_host] && OODClusters[@workflow.batch_host].login_allow?
  end
  json.set! 'terminal_base', OodAppkit.shell.url(path: File.dirname(file.path), host: hostname).to_s
  json.set! 'apiurl', Filesystem.new.api(file.path)
  json.set! 'editor_url', Filesystem.new.editor(file.path)
end
