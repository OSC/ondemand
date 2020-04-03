class RemoveAttrsFromOscJobs < ActiveRecord::Migration[4.2]
  def change
    add_column :osc_jobs, :job_attrs, :string
    remove_column :osc_jobs, :name, :string
    remove_column :osc_jobs, :batch_host, :string
    remove_column :osc_jobs, :staged_dir, :string
    remove_column :osc_jobs, :script_name, :string
  end
end
