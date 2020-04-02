class AddJsonAttrsAsSeparateColsToWorkflow < ActiveRecord::Migration[4.2]
  class Workflow < ActiveRecord::Base
    # store :job_attrs, accessors: [ :name, :batch_host, :staged_dir, :script_name ], coder: JSON
    store :job_attrs, coder: JSON
  end

  def change
    add_column :workflows, :name, :string
    add_column :workflows, :batch_host, :string
    add_column :workflows, :staged_dir, :string
    add_column :workflows, :script_name, :string

    # migrate data if it exists
    Workflow.all.each do |w|
      w.name = w.job_attrs[:name]
      w.batch_host = w.job_attrs[:batch_host]
      w.staged_dir = w.job_attrs[:staged_dir]
      w.script_name = w.job_attrs[:script_name]
      w.save
    end
  end
end
