class AddNotesToTemplate < ActiveRecord::Migration
  def change
    add_column :templates, :notes, :string
  end
end
