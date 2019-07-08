class RemoveLimitFromJobAttrs < ActiveRecord::Migration
  def change
    change_column :osc_jobs, :job_attrs, :text, :limit => nil
  end
end
