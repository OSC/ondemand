json.extract! @osc_job, :name, :batch_host, :staged_dir, :created_at, :updated_at
json.script_path @osc_job.script_path
json.folder_contents @folder_contents
