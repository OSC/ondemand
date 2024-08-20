# Helper for /activejobs pages.
module ActiveJobsHelper

	def build_ganglia_link( host, start_seconds, report_type, node_num, size )
    ganglia_uri = ""
    c = OODClusters[host]
    if c && c.custom_allow?(:ganglia)
      server = c.custom_config(:ganglia)
      ganglia_base = "#{server[:scheme]}#{server[:host]}/#{server[:segments].join('')}"
      cluster_query = server.fetch(:req_query, {}).map { |k,v| "#{k}=#{v}" }[0]
      ganglia_server = server.fetch(:opt_query, {}).fetch('h', '') % {h: node_num }
      ganglia_uri = ("#{ganglia_base}?#{cluster_query}&z=#{size}&cs=#{start_seconds.to_s}&g=#{report_type}&h=#{ganglia_server}").html_safe
    end
    ganglia_uri
  rescue
    nil
  end

  def build_grafana_link(cluster, start_seconds, report_type, node_num, jobid = nil) 
    c = OODClusters[cluster]
    grafana_uri = nil
    if c && c.custom_allow?(:grafana)
      server = c.custom_config(:grafana)
      cluster = server.fetch(:cluster_override, cluster)
      query_params = {
        orgId: server[:orgId],
        theme: server[:theme] || 'light',
        from: "#{start_seconds}000",
        to: 'now',
        "var-#{server[:labels]['cluster']}": cluster,
        "var-#{server[:labels]['host']}": node_num.split('.')[0],
      }
      if ['cpu','memory'].include?(report_type)
        url_base = 'd-solo'
        query_params[:panelId] = server[:dashboard]['panels'][report_type]
      else
        url_base = 'd'
      end
      if jobid
        jobid = jobid.split('.')[0]
        query_params["var-#{server[:labels]['jobid']}"] = jobid unless server[:labels]['jobid'].nil?
      end
      uri = Addressable::Template.new("#{server[:host]}{/segments*}/{?query*}")
      grafana_uri = uri.expand({
        'segments' => [url_base, server[:dashboard]['uid'], server[:dashboard]['name']],
        'query'    => query_params,
        }).to_s
    end
    grafana_uri
  rescue StandardError => e
    puts "ERROR: #{e}"
    nil
  end

  def has_ganglia(host)
    OODClusters[host].try { |cluster| cluster.custom_allow?(:ganglia) } || false
  end

  def has_grafana(host)
    OODClusters[host].try { |cluster| cluster.custom_allow?(:grafana) } || false
  end

  def status_label(status)
    "<span class='badge #{status_class(status)}'>#{status_text(status)}</span>".html_safe
  end

  def filters
    ::ActiveJobs::Filter.list
  end

  def default_filter_id
    ::ActiveJobs::Filter.default_id.to_s
  end
end
