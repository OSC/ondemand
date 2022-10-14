module ActiveJobs
  # Utility class to be able to filter the activejobs by some dimension.
  class Filter
    attr_accessor :title, :filter_id, :filter_block

    class << self
      attr_accessor :list
    end

    def initialize(title: nil, filter_id: nil, &filter_block)
      @title = title
      @filter_id = filter_id
      @filter_block = filter_block
    end

    # Apply the current filtering proc to an array of jobs.
    #
    # @return [Array] The filtered array.
    def apply(job_array)
      self.filter_block ? job_array.select(&filter_block) : job_array
    end

    # Provide the filter_id to be used for the default filter.
    #
    # @return [String] The id of the default filter
    def self.default_id
      "user"
    end

    def user?
      filter_id == "user"
    end

    def all?
      filter_id == "all"
    end

    # Maintains a list of Filter objects.
    #
    # Add new filter objects via the format:
    # self.list << Filter.new.tap { |f|
    #   user = OodSupport::User.new.name
    #   f.title = "Your Jobs"
    #   f.filter_id = "user"
    #   f.filter_block = Proc.new { |job| job.job_owner == user }
    # }

    def self.all_filter
      Filter.new(title: "All Jobs", filter_id: "all")
    end

    # Add a filter by user option.
    #   The actual filtering for the particular user is handled in the controller
    #   via the user_where_owner optimization in ood_core.
    def self.user_filter
      Filter.new(title: "Your Jobs", filter_id: "user")
    end

    # Maintains a list of Filter objects.
    self.list = [user_filter, all_filter]
  end
end
