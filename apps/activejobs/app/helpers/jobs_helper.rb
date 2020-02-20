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

  def has_ganglia(host)
    OODClusters[host].try { |cluster| cluster.custom_allow?(:ganglia) } || false
  end
end
