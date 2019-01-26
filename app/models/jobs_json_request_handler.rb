class JobsJsonRequestHandler
  attr_reader :controller, :params, :response, :filter_id, :cluster_id

  def initialize(filter_id:, cluster_id:, controller:, params:, response:)
    @filter_id = filter_id
    @cluster_id = cluster_id
    @controller = controller
    @params = params
    @response = response
  end

  def filter
    @filter ||= Filter.list.find(Filter.all_filter) { |f| f.filter_id == filter_id  }
  end

  def clusters
    if cluster_id == 'all'
      OODClusters
    else
      OODClusters.select { |c| c == cluster_id}
    end
  end

  def job_info_enumerator(cluster)
    if filter.user?
      cluster.job_adapter.info_where_owner_each(OodSupport::User.new.name)
    else
      cluster.job_adapter.info_all_each
    end
  end

  def render
    response.content_type = Mime[:json]

    errors = []
    count = 0
    response.stream.write '{"data":[' # data is now an array of arrays']}'

    clusters.each_with_index do |cluster|
      begin
        job_info_enumerator(cluster).each_slice(3000) do |jobs|
          jobs = convert_info_filtered(filter.apply(jobs), cluster)

          response.stream.write "," if count > 0
          response.stream.write jobs.to_json

          controller.logger.debug "wrote jobs to stream: #{jobs.count}"
          count += 1;
        end
      rescue => e
        msg = "#{cluster.metadata.title || cluster.id.to_s.titleize}: #{e.message}"
        controller.logger.error "#{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
        errors << msg
      end
    end

    response.stream.write '], "errors":' + errors.to_json + '}'
  ensure
    response.stream.close
  end

  def convert_info(info_all, cluster)
    extended_available = %w(torque slurm lsf pbspro).include?(cluster.job_config[:adapter])

    info_all.map { |j|
      {
        cluster_title: cluster.metadata.title || cluster.id.to_s.titleize,
        status: status_for_job(j),
        cluster: cluster.id.to_s,
        pbsid: j.id,
        jobname: j.job_name,
        account: j.accounting_id,
        queue: j.queue_name,
        walltime_used: j.wallclock_time,
        username: j.job_owner,
        extended_available: extended_available
      }
    }
  end

  # FIXME: remove when LSF and PBSPro are confirmed to handle job ids gracefuly
  def convert_info_filtered(info_all, cluster)
    if %w(lsf pbspro).include?(cluster.job_config[:adapter])
      rx = Regexp.new(/\[/)
      convert_info(info_all.reject {|job| rx.match?(job.id) }, cluster)
    else
      convert_info(info_all, cluster)
    end
  end

  def status_for_job(job)
    status_label(job.status.state.to_s)
  end

  def status_label(status)
    case status
    when "completed"
      label = "Completed"
      labelclass = "label-success"
    when "running"
      label = "Running"
      labelclass = "label-primary"
    when "queued"
      label = "Queued"
      labelclass = "label-info"
    when "queued_held"
      label = "Hold"
      labelclass = "label-warning"
    when "suspended"
      label = "Suspend"
      labelclass = "label-warning"
    else
      label = "Undetermined"
      labelclass = "label-default"
    end
    "<div style='white-space: nowrap;'><span class='label #{labelclass}'>#{label}</span></div>".html_safe
  end
end
