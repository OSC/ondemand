class AddTimestampsToToJsonStores < ActiveRecord::Migration[4.2]
  def change
    add_column :json_stores, :created_at, :datetime
    add_column :json_stores, :updated_at, :datetime
  end
end
