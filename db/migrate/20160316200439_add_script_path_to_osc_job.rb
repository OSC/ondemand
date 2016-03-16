class AddScriptPathToOscJob < ActiveRecord::Migration
  def change
    add_column :osc_jobs, :script_path, :string
  end
end
