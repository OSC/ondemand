json.(@transfer, :id, :created_at, :started_at, :completed_at, :fa_label, :bootstrap_class)
json.running @transfer.status.running?
json.completed @transfer.status.completed?
json.message @transfer.to_s
json.error_message alert if alert
