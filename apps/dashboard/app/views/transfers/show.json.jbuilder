json.(@transfer, :id, :created_at, :started_at, :completed_at, :fa_label, :bootstrap_class)
json.target_dir @transfer.target_dir.to_s
json.running @transfer.status.running?
json.completed @transfer.status.completed?

json.summary @transfer.to_s

json.show_html_url transfer_path(@transfer.id, format: 'html') if @transfer.id
json.show_json_url transfer_path(@transfer.id, format: 'json') if @transfer.id

json.error_message @transfer.errors.full_messages.join("\n\n") if @transfer.errors.any?
json.error_summary "An error occurred: #{@transfer.action_title}" if @transfer.errors.any?
