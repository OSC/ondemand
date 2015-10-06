# Model for view data from PBS-Ruby response.
#
# The PBS-Ruby results are much larger than this app needs them to be
# so this model extracts the necessary info to send to the user.
#
# @author Brian L. McMichael
# @version 0.0.1
class Jobstatusdata

  attr_reader :pbsid, :jobname, :username, :status, :cluster

  # Set the object to the server.
  #
  # @return [Jobstatusdata] self
  def initialize(pbs_job)
    self.pbsid = pbs_job[:name]
    self.jobname = pbs_job[:attribs][:Job_Name]
    self.username = username(pbs_job[:attribs][:Job_Owner])
    self.status = pbs_job[:attribs][:job_state]
    self.cluster = hostname(pbs_job[:attribs][:submit_host])
    self
  end

  private

    def username(attribs_Job_Owner)
      attribs_Job_Owner.split('@')[0]
    end

    def hostname(attribs_submit_host)
      attribs_submit_host.split(/\d+/)[0]

      # We may want to split after the number.
      # PBS returns jobs running  on Websvcs and N000 nodes,
      # and the above line cuts the digits.
      #attribs_submit_host.split('.')[0].capitalize
    end

    attr_writer :pbsid, :jobname, :username, :status, :cluster

end
