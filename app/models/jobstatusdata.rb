# Model for view data from PBS-Ruby response.
#
# The PBS-Ruby results are much larger than this app needs them to be
# so this model extracts the necessary info to send to the user.
#
# @author Brian L. McMichael
# @version 0.0.1
class Jobstatusdata
  include ApplicationHelper
  attr_reader :pbsid, :jobname, :username, :account, :status, :cluster, :nodes, :starttime, :walltime, :walltime_used, :submit_args, :output_path, :nodect, :ppn, :total_cpu, :queue, :cput, :mem, :vmem, :shell_url, :file_explorer_url, :extended_available, :native_attribs

  Attribute = Struct.new(:name, :value)


  # Define an object containing only necessary data to send to client.
  #
  # Object defaults to condensed data, add extended flag to initializer to include all data used by the application.
  #
  # @param [Hash] info An OodCore.job_adapter.info[_all] response hash
  # @param [String] cluster The string name of a cluster configured in the OODClusters list (ex. 'oakley')
  # @param [Boolean, nil] extended If true, included extended data in the response (default: false)
  # @return [Jobstatusdata] self
  def initialize(info, cluster=OODClusters.first.id.to_s, extended=false)
    self.pbsid = info.id
    self.jobname = info.job_name
    self.username = info.job_owner
    self.account = info.accounting_id
    self.status = status_label(info.status.state.to_s)
    self.cluster = cluster
    self.walltime_used = info.wallclock_time.to_i > 0 ? pretty_time(info.wallclock_time) : ''
    self.queue = info.queue_name
    if info.status == :running || info.status == :completed
      self.nodes = node_array(info.allocated_nodes)
      self.starttime = info.dispatch_time.to_i
    end
    # TODO Find a better way to distingush whether a native parser is available. Maybe this is fine?
    self.extended_available = OODClusters[cluster].job_config[:adapter] == "torque" || OODClusters[cluster].job_config[:adapter] == "slurm"
    if extended
      if OODClusters[cluster].job_config[:adapter] == "torque"
        extended_data_torque(info)
      elsif OODClusters[cluster].job_config[:adapter] == "slurm"
        extended_data_slurm(info)
      else
        extended_data_default(info)
      end
    end
    self
  end

  # Store additional data about the job. (Torque-specific)
  #
  # Parses the `native` info function for additional information about jobs on Torque systems.
  #
  # @return [Jobstatusdata] self
  def extended_data_torque(info)
    return unless info.native
    attributes = []
    attributes.push Attribute.new "PBS Id", self.pbsid
    attributes.push Attribute.new "Job Name", self.jobname
    attributes.push Attribute.new "User", self.username
    attributes.push Attribute.new "Account", self.account
    attributes.push Attribute.new "Walltime", (info.native.fetch(:Resource_List, {})[:walltime].presence || "00:00:00")
    node_count = info.native.fetch(:Resource_List, {})[:nodect].to_i
    attributes.push Attribute.new "Node Count", node_count
    ppn = info.native[:Resource_List][:nodes].to_s.split("ppn=").second || '0'
    attributes.push Attribute.new "PPN", ppn
    attributes.push Attribute.new "Total CPUs", ppn.to_i * node_count.to_i
    attributes.push Attribute.new "CPU Time", info.native.fetch(:resources_used, {})[:cput].presence || '0'
    attributes.push Attribute.new "Memory", info.native.fetch(:resources_used, {})[:mem].presence || "0 b"
    attributes.push Attribute.new "Virtual Memory", info.native.fetch(:resources_used, {})[:vmem].presence || "0 b"
    self.native_attribs = attributes

    self.submit_args = info.native[:submit_args].presence || "None"
    self.output_path = info.native[:Output_Path].to_s.split(":").second || info.native[:Output_Path]

    output_pathname = Pathname.new(self.output_path).dirname
    set_file_explorer_url(output_pathname)
    set_shell_url(output_pathname, self.cluster)

    self
  end

  # Store additional data about the job. (SLURM-specific)
  #
  # Parses the `native` info function for additional information about jobs on SLURM systems.
  #
  # @return [Jobstatusdata] self
  def extended_data_slurm(info)
    return unless info.native
    attributes = []
    attributes.push Attribute.new "Job Id", self.pbsid
    attributes.push Attribute.new "Job Name", self.jobname
    attributes.push Attribute.new "User", self.username
    attributes.push Attribute.new "Account", self.account
    attributes.push Attribute.new "Partition", self.queue
    attributes.push Attribute.new "Cluster", self.cluster
    attributes.push Attribute.new "State", info.native[:state]
    attributes.push Attribute.new "Reason", info.native[:reason]
    attributes.push Attribute.new "Total Nodes", info.native[:nodes]
    attributes.push Attribute.new "Total CPUs", info.native[:cpus]
    attributes.push Attribute.new "Time Limit", info.native[:time_limit]
    attributes.push Attribute.new "Time Used", info.native[:time_used]
    attributes.push Attribute.new "Memory", info.native[:min_memory]
    self.native_attribs = attributes

    self.submit_args = nil
    self.output_path = info.native[:work_dir]

    output_pathname = Pathname.new(info.native[:work_dir])
    set_file_explorer_url(output_pathname)
    set_shell_url(output_pathname, self.cluster)

    self
  end

  # This should not be called, but it is available as a template for building new native parsers.
  def extended_data_default(info)
    return unless info.native

    self.native_attribs = []

    self.submit_args = ''
    self.output_path = ''

    output_pathname = Pathname.new(ENV["HOME"])
    set_file_explorer_url(output_pathname)
    set_shell_url(output_pathname, self.cluster)

    self
  end

  private

    def set_file_explorer_url(path)
      writable_path = (path.writable? ? path : ENV["HOME"]).to_s

      self.file_explorer_url = OodAppkit.files.url(path: writable_path).to_s
    end

    def set_shell_url(path, cluster)
      writable_path = (path.writable? ? path : ENV["HOME"]).to_s
      host = OODClusters[cluster].login.host if OODClusters[cluster] && OODClusters[cluster].login_allow?

      self.shell_url = OodAppkit.shell.url(path: writable_path, host: host).to_s
    end

    # Rails default string formatters only support HH:MM:SS and roll over the days, so we need to create our own.
    #
    # @param [Integer] The time in seconds
    # @return [String] The time as string formatted as "DDd HH:MM"
    def pretty_time(seconds)
      duration=Array.new
      units=[ [":", 60*60], [":", 60], ["", 1] ]
      units.each do |value|
        unit = seconds.divmod(value[1])
        duration.push("#{"%02d" % unit[0]}#{value[0]}")
        seconds = unit[1]
      end

      return duration.join('')
    end

    # Converts the `allocated_nodes` object array into an array of node names
    #
    # @example [#<OodCore::Job::NodeInfo:0x00000009d3ff78 @name="n0544", @procs=2>] => ['n0544']
    #
    # @param [Array<OodCore::Job::NodeInfo>]
    # @return [Array<String>] the nodes as array
    def node_array(node_info_array)
      node_info_array.map { |n| n.name }
    end

    attr_writer :pbsid, :jobname, :username, :account, :status, :cluster, :nodes, :starttime, :walltime, :walltime_used, :submit_args, :output_path, :nodect, :ppn, :total_cpu, :queue, :cput, :mem, :vmem, :shell_url, :file_explorer_url, :extended_available, :native_attribs

end
