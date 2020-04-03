class CreateTemplates < ActiveRecord::Migration[4.2]
  def change
    create_table :templates do |t|
      t.string :name
      t.string :path

      t.timestamps
    end
  end
end
