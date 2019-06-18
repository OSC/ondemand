module JobsHelper

	def build_ganglia_link( host, start_seconds, report_type, node_num, size )
    OODClusters.each do |c|
      if host.eql?(c.id.to_s)
        if c.custom_allow?(:ganglia)
          @ganglia_cluster = OodCluster::Servers::Ganglia.new(c.custom_config(:ganglia))
          @ganglia_base = @ganglia_cluster.uri.to_s
          @ganglia_server = @ganglia_cluster.opt_query.fetch(:h, '') % {h: node_num }
          @ganglia_uri = (@ganglia_base + '&z=' + size + '&cs=' + start_seconds.to_s + '&g=' + report_type+ "&h=" + @ganglia_server).html_safe
        end
      end
    end
    @ganglia_uri
  end

  def has_ganglia(host)
    @flag = false
    OODClusters.each do |c|
      if host.eql?(c.id.to_s)
        if c.custom_allow?(:ganglia)
          @flag = true
        end
      end
    end
    @flag
  end
end
