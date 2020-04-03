class RenameOscJobIdToWorkflowId < ActiveRecord::Migration[4.2]
  def change
  	rename_column :jobs, :osc_job_id, :workflow_id
  end
end
