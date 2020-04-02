class CreateOscJobJobs < ActiveRecord::Migration[4.2]
  def change
    create_table :osc_job_jobs do |t|
      t.references :osc_job, index: true
      t.string :status
      t.text :job_cache

      t.timestamps
    end
  end
end
