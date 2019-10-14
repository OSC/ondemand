class RenameOscJobJobToJob < ActiveRecord::Migration
  def change
    rename_table :osc_job_jobs, :jobs
  end
end
