class RenameScriptPathColumnToScriptName < ActiveRecord::Migration[4.2]
  def change
    rename_column :osc_jobs, :script_path, :script_name
  end
end
