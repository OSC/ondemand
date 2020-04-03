class DropTableTemplates < ActiveRecord::Migration[4.2]
  def change
    drop_table :templates
  end
end
