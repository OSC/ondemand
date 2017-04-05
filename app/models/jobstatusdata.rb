# Model for view data from PBS-Ruby response.
#
# The PBS-Ruby results are much larger than this app needs them to be
# so this model extracts the necessary info to send to the user.
#
# @author Brian L. McMichael
# @version 0.0.1
class Jobstatusdata

  attr_reader :pbsid, :jobname, :username, :account, :status, :cluster, :nodes, :starttime, :walltime, :walltime_used, :submit_args, :output_path, :nodect, :ppn, :total_cpu, :queue, :cput, :mem, :vmem, :terminal_path, :fs_path, :extended_available

  # Define an object containing only necessary data to send to client.
  #
  # Object defaults to condensed data, add extended flag to initializer to include all data used by the application.
  #
  # @return [Jobstatusdata] self
  def initialize(info, cluster=OODClusters.first.id.to_s, extended=false)
    self.pbsid = info.id
    self.jobname = info.job_name
    self.username = info.job_owner
    self.account = info.accounting_id
    self.status = info.status.state
    self.cluster = cluster
    self.walltime_used = info.wallclock_time > 0 ? pretty_time(info.wallclock_time) : ''
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
    self.walltime = info.native.fetch(:Resource_List, {})[:walltime].presence || "00:00:00"
    self.submit_args = info.native[:submit_args].presence || "None"
    self.output_path = info.native[:Output_Path].to_s.split(":").second || info.native[:Output_Path]
    self.nodect = info.native.fetch(:Resource_List, {})[:nodect].to_i
    self.ppn = info.native[:Resource_List][:nodes].to_s.split("ppn=").second || '0'
    self.total_cpu = self.ppn[/\d+/].to_i * self.nodect.to_i
    self.cput = info.native.fetch(:resources_used, {})[:cput].presence || '0'
    mem = info.native.fetch(:resources_used, {})[:mem].presence || "0 b"
    self.mem = Filesize.from(mem).pretty
    vmem = info.native.fetch(:resources_used, {})[:vmem].presence || "0 b"
    self.vmem = Filesize.from(vmem).pretty
    output_pathname = Pathname.new(self.output_path).dirname
    self.terminal_path = OodAppkit.shell.url(path: (output_pathname.writable? ? output_pathname : ENV["HOME"])).to_s
    self.fs_path = OodAppkit.files.url(path: (output_pathname.writable? ? output_pathname : ENV["HOME"])).to_s
    if self.status == :running || self.status == :completed
      self.nodes = node_array(info.allocated_nodes)
      self.starttime = info.dispatch_time.to_i
    end
    self
  end

  # Store additional data about the job. (SLURM-specific)
  #
  # Parses the `native` info function for additional information about jobs on SLURM systems.
  #
  # @return [Jobstatusdata] self
  def extended_data_slurm(info)
    self.walltime = info.native[:time_limit]
    self.submit_args = info.native[:command]
    self.output_path = info.native[:work_dir]            # FIXME This is the working directory (i.e. /scratch ) and may not be the output dir
    self.nodect = info.native[:nodes].to_i               # Nodes Requested
    self.ppn = info.procs / self.nodect                  # FIXME This may not be accurate on Slurm systems
    self.total_cpu = info.procs
    self.cput = info.native[:time_used]
    self.mem = info.native[:min_memory].presence || "0 b"
    self.vmem = info.native[:min_memory].presence || "0 b"
    output_pathname = Pathname.new(info.native[:work_dir]).dirname
    self.terminal_path = OodAppkit.shell.url(path: (output_pathname.writable? ? output_pathname : ENV["HOME"])).to_s
    self.fs_path = OodAppkit.files.url(path: (output_pathname.writable? ? output_pathname : ENV["HOME"])).to_s
    if self.status == :running || self.status == :completed
      self.nodes = node_array(info.allocated_nodes)
      self.starttime = info.dispatch_time.to_i
    end
    self
  end

  # This should not be called, but it is available as a template for building new native parsers.
  def extended_data_default(info)
    self.walltime = ''
    self.submit_args = ''
    self.output_path = ''
    self.nodect = 0
    self.ppn = ''
    self.total_cpu = info.procs
    self.cput = ''
    mem = "0 b"
    self.mem = Filesize.from(mem).pretty
    vmem = "0 b"
    self.vmem = Filesize.from(vmem).pretty
    output_pathname = Pathname.new(ENV["HOME"])
    self.terminal_path = '' #OodAppkit.shell.url(path: (output_pathname.writable? ? output_pathname : ENV["HOME"]))
    self.fs_path = '' #OodAppkit.files.url(path: (output_pathname.writable? ? output_pathname : ENV["HOME"]))
    if self.status == :running || self.status == :completed
      self.nodes = node_array(info.allocated_nodes)
      self.starttime = info.dispatch_time.to_i
    end
    self
  end

  private

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

    attr_writer :pbsid, :jobname, :username, :account, :status, :cluster, :nodes, :starttime, :walltime, :walltime_used, :submit_args, :output_path, :nodect, :ppn, :total_cpu, :queue, :cput, :mem, :vmem, :terminal_path, :fs_path, :extended_available

end
