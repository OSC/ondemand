json.extract! @osc_job, :name, :batch_host, :script_path, :staged_script_name, :staged_dir, :created_at, :updated_at, :status
json.set! 'fs_root', Filesystem.new.fs(@osc_job.staged_dir)
json.folder_contents do
  @folder_contents.each do |content|
     json.set! 'content', content
     json.set! 'type', Pathname(content).file? ? 'file' : 'dir'
     json.set! 'fsurl', Filesystem.new.fs(content)
     json.set! 'apiurl', Filesystem.new.api(content)
  end
end
