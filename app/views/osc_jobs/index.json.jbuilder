json.array!(@osc_jobs) do |osc_job|
  json.extract! osc_job, :name, :batch_host
  json.url osc_job_url(osc_job, format: :json)
end
