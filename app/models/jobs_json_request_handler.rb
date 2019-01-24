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

  def render
    controller.render :json => get_jobs
  end

  # Get a set of jobs defined by the filtering parameter.
  def get_jobs
    jobs = Array.new
    errors = Array.new

    clusters.each do |cluster|
      begin
        if filter.user?
          result = cluster.job_adapter.info_where_owner(OodSupport::User.new.name)
        else
          result = filter.apply(cluster.job_adapter.info_all)
        end

        # Only add the running jobs to the list and assign the host to the object.
        #
        # There is also curently a bug in the system where jobs with an empty array
        # (ex. 6407991[].oak-batch.osc.edu) are not stattable, so we do a not-match
        # for those jobs and don't display them.
        result.each do |j|
          if j.status.state != :completed && j.id !~ /\[\]/
            jobs.push(Jobstatusdata.new(j, cluster))
          end
        end
      rescue => e
        msg = "#{cluster.metadata.title || cluster.id.to_s.titleize}: #{e.message}"
        controller.logger.error "#{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
        errors << msg
      end
    end

    # Sort jobs by username
    jobs.sort_by! do |user|
      user.username == OodSupport::User.new.name ? 0 : 1
    end

    { data: jobs, errors: errors }
  end
end
