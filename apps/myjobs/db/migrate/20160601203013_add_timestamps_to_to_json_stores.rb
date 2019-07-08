class AddTimestampsToToJsonStores < ActiveRecord::Migration
  def change
    add_column :json_stores, :created_at, :datetime
    add_column :json_stores, :updated_at, :datetime
  end
end
