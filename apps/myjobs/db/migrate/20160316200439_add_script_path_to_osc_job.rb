class AddScriptPathToOscJob < ActiveRecord::Migration[4.2]
  def change
    add_column :osc_jobs, :script_path, :string
  end
end
