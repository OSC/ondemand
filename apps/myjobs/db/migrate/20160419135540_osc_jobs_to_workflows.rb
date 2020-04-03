class OscJobsToWorkflows < ActiveRecord::Migration[4.2]
  def change
    rename_table :osc_jobs, :workflows
  end
end
