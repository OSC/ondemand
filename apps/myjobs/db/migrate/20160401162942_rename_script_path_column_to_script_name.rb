class RenameScriptPathColumnToScriptName < ActiveRecord::Migration
  def change
    rename_column :osc_jobs, :script_path, :script_name
  end
end
