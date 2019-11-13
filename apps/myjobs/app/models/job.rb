class Job < ActiveRecord::Base
  include OscMacheteRails::Statusable

  belongs_to :workflow

  # Determine if the results are valid
  # def results_valid?
  #   # CODE GOES HERE
  # end

  # we inline the construction of this job object
  # so we can include a custom TorqueAdapter
  def job
    OSC::Machete::Job.new(
      script: script,
      pbsid: pbsid,
      host: host || workflow.batch_host,
      torque_helper: ResourceMgrAdapter.new(workflow)
    )
  end

  def xdmod_url
    "8366777.owens-batch.ten.osc.edu => 8366777"
    resource_id = {
      "owens" => 1,
      "ruby" => 2,
      "oakley" => 3,
      "pitzer" => 4
    }[host]

    "https://xdmod-test.hpc.osc.edu/index.php#job_viewer?action=show&realm=SUPREMM&resource_id=#{resource_id}&local_job_id=#{pbsid_number}"
  end

  def pbsid_number
    @pbsid_number ||= pbsid.scan(/\d+/).first
  end
end
