module ActiveJobs
  # Utility class for responding to json activejobs requests. This class generates
  # the resulting json body that the controller will ultimately repond with.
  class JobsJsonRequestHandler
    attr_reader :controller, :params, :response, :filter_id, :cluster_id

    # additional attrs to request when calling info_all
    JOB_ATTRS = [:accounting_id, :allocated_nodes, :job_name, :job_owner, :queue_name, :wallclock_time ]

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
      elsif cluster_id.nil? # FIXME: because of bug in ood_core https://github.com/OSC/ood_core/issues/129
        []
      else
        OODClusters.select { |c| c == cluster_id}
      end
    end

    def job_info_enumerator(cluster)
      if filter.user?
        cluster.job_adapter.info_where_owner_each(OodSupport::User.new.name, attrs: JOB_ATTRS)
      else
        cluster.job_adapter.info_all_each(attrs: JOB_ATTRS)
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

      errors << "No clusters found for cluster id: #{cluster_id}" if clusters.to_a.empty?

      response.stream.write '], "errors":' + errors.to_json + '}'
    ensure
      response.stream.close
    end

    def convert_info(info_all, cluster)
      extended_available = %w(torque slurm lsf pbspro sge).include?(cluster.job_config[:adapter])

      info_all.map { |j|
        {
          cluster_title: cluster.metadata.title || cluster.id.to_s.titleize,
          status: j.status.state.to_s,
          cluster: cluster.id.to_s,
          pbsid: j.id,
          jobname: j.job_name,
          account: j.accounting_id.to_s,
          queue: j.queue_name,
          walltime_used: j.wallclock_time,
          username: j.job_owner,
          extended_available: extended_available,
          nodes: j.allocated_nodes.map{ |node| node.name }.reject(&:blank?),
          delete_path: users_job?(j.job_owner) ? UrlHelper.instance.delete_job_path(pbsid: j.id, cluster: cluster.id.to_s) : ""
        }
      }
    end

    # FIXME: remove when LSF and PBSPro are confirmed to handle job ids gracefuly
    def convert_info_filtered(info_all, cluster)
      if cluster.job_adapter.supports_job_arrays?
        convert_info(info_all, cluster)
      else
        rx = Regexp.new(/\[/)
        convert_info(info_all.reject {|job| rx.match?(job.id) }, cluster)
      end
    end

    # small helper to just cache the @user
    def users_job?(owner)
      @user ||= ENV["USER"]
      owner == @user
    end
  end

  class UrlHelper
    include Singleton
    include Rails.application.routes.url_helpers
  end
end
