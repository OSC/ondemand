class AddNotesToTemplate < ActiveRecord::Migration[4.2]
  def change
    add_column :templates, :notes, :string
  end
end
