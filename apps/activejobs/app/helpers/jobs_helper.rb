module JobsHelper

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
    if c && c.custom_allow?(:grafana)
      server = c.custom_config(:grafana)
      host = node_num.split('.')[0]
      dashboard = server[:dashboard]
      dashboard_url = "#{dashboard['uid']}/#{dashboard['name']}"
      query_params = {
        orgId: server[:orgId],
        from: "#{start_seconds}000",
        to: 'now',
        "var-#{server[:labels]['cluster']}": cluster,
        "var-#{server[:labels]['host']}": host,
      }
      if ['cpu','memory'].include?(report_type)
        url_base = 'd-solo'
        panel_id = dashboard['panels'][report_type]
        query_params[:panelId] = panel_id
      else
        url_base = 'd'
      end
      if jobid
        jobid = jobid.split('.')[0]
        query_params["var-#{server[:labels]['jobid']}"] = jobid unless server[:labels]['jobid'].nil?
      end
      query_params = query_params.map { |k,v| "#{k}=#{v}" }.join('&')
      grafana_uri = ("#{server[:host]}/#{url_base}/#{dashboard_url}?#{query_params}").html_safe
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
end
