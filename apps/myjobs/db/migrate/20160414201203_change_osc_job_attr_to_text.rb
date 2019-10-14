class ChangeOscJobAttrToText < ActiveRecord::Migration
  def change
    change_column :osc_jobs, :job_attrs, :text
  end
end
