class CreateJsonStore < ActiveRecord::Migration
  def change
    create_table :json_stores do |t|
      t.text :json_attrs
      t.string :type
      t.index :type
    end
  end
end
