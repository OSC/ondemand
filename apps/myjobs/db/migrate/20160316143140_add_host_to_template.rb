class AddHostToTemplate < ActiveRecord::Migration[4.2]
  def change
    add_column :templates, :host, :string
  end
end
