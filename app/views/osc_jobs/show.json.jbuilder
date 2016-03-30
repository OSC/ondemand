json.extract! @osc_job, :name, :batch_host, :script_path, :staged_script_name, :staged_dir, :created_at, :updated_at, :status
json.set! 'status_label', status_label(@osc_job)
json.set! 'fs_root', Filesystem.new.fs(@osc_job.staged_dir)
json.folder_contents (@osc_job.folder_contents) do |content|
  json.set! 'path', content
  json.set! 'name', Pathname(content).basename.to_s
  json.set! 'type', Pathname(content).file? ? 'file' : 'dir'
  json.set! 'fsurl', Filesystem.new.fs(content)
  json.set! 'fs_base', Filesystem.new.fs(File.dirname(content))
  json.set! 'apiurl', Filesystem.new.api(content)
end
