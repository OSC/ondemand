class OscJobsToWorkflows < ActiveRecord::Migration
  def change
    rename_table :osc_jobs, :workflows
  end
end
