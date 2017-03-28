# Model for view data from PBS-Ruby response.
#
# The PBS-Ruby results are much larger than this app needs them to be
# so this model extracts the necessary info to send to the user.
#
# @author Brian L. McMichael
# @version 0.0.1
class Jobstatusdata

  attr_reader :pbsid, :jobname, :username, :account, :status, :cluster, :nodes, :starttime, :walltime, :walltime_used, :submit_args, :output_path, :nodect, :ppn, :total_cpu, :queue, :cput, :mem, :vmem, :terminal_path, :fs_path

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
    if self.status == :running || self.status == :completed
      # FIXME :exec_host is torque-specific, IIRC it's used to pre-build the ganglia links and speed up the frontend load
      # Move this out asap
      self.nodes = node_array(info.native[:exec_host])
      self.starttime = info.dispatch_time
    end
    self.cluster = cluster
    if extended
      if OODClusters[cluster].job_config[:adapter] == "torque"
        extended_data_torque(info)
      else
        extended_data_default(info)
      end
    end
    self
  end

  # Store additional data about the job.
  #
  # @return [Jobstatusdata] self
  def extended_data_torque(info)
    self.walltime = info.native[:Resource_List][:walltime]
    self.walltime_used = info.native.fetch(:resources_used, {})[:walltime].presence || 0
    self.submit_args = info.native[:submit_args].presence || "None"
    self.output_path = info.native[:Output_Path].to_s.split(":").second || pbs_job[:attribs][:Output_Path]
    self.nodect = info.native[:Resource_List][:nodect]
    self.ppn = info.native[:Resource_List][:nodes].to_s.split("ppn=").second || 0
    self.total_cpu = self.ppn[/\d+/].to_i * self.nodect.to_i
    self.queue = info.native[:queue]
    self.cput = info.native.fetch(:resources_used, {})[:cput].presence || 0
    mem = info.native.fetch(:resources_used, {})[:mem].presence || "0 b"
    self.mem = Filesize.from(mem).pretty
    vmem = info.native.fetch(:resources_used, {})[:vmem].presence || "0 b"
    self.vmem = Filesize.from(vmem).pretty
    output_pathname = Pathname.new(self.output_path).dirname
    self.terminal_path = OodAppkit.shell.url(path: (output_pathname.writable? ? output_pathname : ENV["HOME"]))
    self.fs_path = OodAppkit.files.url(path: (output_pathname.writable? ? output_pathname : ENV["HOME"]))
    self
  end

  def extended_data_default(info)
    self.walltime = ''
    self.walltime_used = ''
    self.submit_args = ''
    self.output_path = ''
    self.nodect = ''
    self.ppn = ''
    self.total_cpu = info.procs
    self.queue = info.queue_name
    self.cput = info.wallclock_time
    mem = "0 b"
    self.mem = Filesize.from(mem).pretty
    vmem = "0 b"
    self.vmem = Filesize.from(vmem).pretty
    output_pathname = ENV["HOME"]
    self.terminal_path = '' #OodAppkit.shell.url(path: (output_pathname.writable? ? output_pathname : ENV["HOME"]))
    self.fs_path = '' #OodAppkit.files.url(path: (output_pathname.writable? ? output_pathname : ENV["HOME"]))
    self
  end

  # Converts the :exec_host string to an array of node numbers
  #
  # @example "n0324/0-11+n0145/0-11+n0144/0-11" => ['n0324', 'n0145', 'n0144']
  #
  # @return [Array] the nodes as array
  def node_array(attribs_exec_host)
    nodes = Array.new
    # Some completed jobs will no longer have nodes associated with them
    # and will return an empty hash. Only process when there are valid nodes.
    if attribs_exec_host.is_a? String
      # Create an array of nodes associcated with the job.
      attribs_exec_host.split('+').each do |node|
        nodes.push(node.split('/')[0])
      end
    end
    nodes
  end

  private

    attr_writer :pbsid, :jobname, :username, :account, :status, :cluster, :nodes, :starttime, :walltime, :walltime_used, :submit_args, :output_path, :nodect, :ppn, :total_cpu, :queue, :cput, :mem, :vmem, :terminal_path, :fs_path

end
