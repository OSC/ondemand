class RemoveLimitFromJobAttrs < ActiveRecord::Migration[4.2]
  def change
    change_column :osc_jobs, :job_attrs, :text, :limit => nil
  end
end
