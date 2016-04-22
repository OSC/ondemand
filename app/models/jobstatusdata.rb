# Model for view data from PBS-Ruby response.
#
# The PBS-Ruby results are much larger than this app needs them to be
# so this model extracts the necessary info to send to the user.
#
# @author Brian L. McMichael
# @version 0.0.1
class Jobstatusdata

  attr_reader :pbsid, :jobname, :username, :group, :status, :cluster, :nodes, :starttime, :walltime, :walltime_used, :submit_args, :output_path, :nodect, :ppn, :total_cpu, :queue, :cput, :mem, :vmem, :terminal_path, :fs_path

  # Define an object containing only necessary data to send to client.
  #
  # Object defaults to condensed data, add extended flag to initializer to include all data used by the application.
  #
  # @return [Jobstatusdata] self
  def initialize(pbs_job, pbs_cluster=Servers.first[0], extended=false)
    self.pbsid = pbs_job[:name]
    self.jobname = pbs_job[:attribs][:Job_Name]
    self.username = username_format(pbs_job[:attribs][:Job_Owner])
    self.group = pbs_job[:attribs][:egroup].empty? ? Etc.getgrgid(Etc.getpwnam(self.username).gid).name : pbs_job[:attribs][:egroup]
    self.status = pbs_job[:attribs][:job_state]
    if self.status == "R" || self.status == "C"
      self.nodes = node_array(pbs_job[:attribs][:exec_host])
      self.starttime = pbs_job[:attribs][:start_time]
    end
    self.cluster = pbs_cluster
    if extended
      extended_data(pbs_job)
    end
    self
  end

  # Store additional data about the job.
  #
  # @return [Jobstatusdata] self
  def extended_data(pbs_job)
    self.walltime = pbs_job[:attribs][:Resource_List][:walltime]
    self.walltime_used = pbs_job[:attribs][:resources_used][:walltime].presence || 0
    self.submit_args = pbs_job[:attribs][:submit_args].presence || "None"
    self.output_path = pbs_job[:attribs][:Output_Path].split(":").second
    self.nodect = pbs_job[:attribs][:Resource_List][:nodect]
    self.ppn = pbs_job[:attribs][:Resource_List][:nodes].split("ppn=").second
    self.total_cpu = self.ppn[/\d+/].to_i * self.nodect.to_i
    self.queue = pbs_job[:attribs][:queue]
    self.cput = pbs_job[:attribs][:resources_used][:cput].presence || 0
    self.mem = pbs_job[:attribs][:resources_used][:mem].presence || 0
    self.vmem = pbs_job[:attribs][:resources_used][:vmem].presence || 0
    output_pathname = Pathname.new(self.output_path).dirname
    self.terminal_path = output_pathname.writable? ? File.join(Terminal[:path], output_pathname).to_s : File.join(Terminal[:path], ENV["HOME"]).to_s
    self.fs_path = output_pathname.writable? ? File.join(FileManager[:fs], output_pathname).to_s : File.join(FileManager[:fs], ENV["HOME"]).to_s
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

  def username_format(attribs_Job_Owner)
    attribs_Job_Owner.split('@')[0]
  end

    attr_writer :pbsid, :jobname, :username, :group, :status, :cluster, :nodes, :starttime, :walltime, :walltime_used, :submit_args, :output_path, :nodect, :ppn, :total_cpu, :queue, :cput, :mem, :vmem, :terminal_path, :fs_path

end
