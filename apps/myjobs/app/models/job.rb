class Job < ApplicationRecord
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
end
