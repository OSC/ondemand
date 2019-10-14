class RenameOscJobIdToWorkflowId < ActiveRecord::Migration
  def change
  	rename_column :jobs, :osc_job_id, :workflow_id
  end
end
