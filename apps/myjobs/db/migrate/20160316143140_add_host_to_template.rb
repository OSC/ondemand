class AddHostToTemplate < ActiveRecord::Migration
  def change
    add_column :templates, :host, :string
  end
end
