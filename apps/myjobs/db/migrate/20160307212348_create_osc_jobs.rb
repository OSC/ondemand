class CreateOscJobs < ActiveRecord::Migration[4.2]
  def change
    create_table :osc_jobs do |t|
      t.string :name
      t.string :batch_host
      t.string :staged_dir

      t.timestamps
    end
  end
end
