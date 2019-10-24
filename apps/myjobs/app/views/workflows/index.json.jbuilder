json.array!(@workflows) do |workflow|
  json.extract! workflow, :name, :batch_host
  json.url workflow_url(workflow, format: :json)
end
