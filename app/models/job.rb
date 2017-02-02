class Job < ActiveRecord::Base
  include OscMacheteRails::Statusable

  belongs_to :workflow

  # Determine if the results are valid
  # def results_valid?
  #   # CODE GOES HERE
  # end

  # TODO: we inline the construction of this job object
  # so we can include a custom TorqueAdapter
  def job
    jobattrs = job_cache.symbolize_keys
    jobattrs[:host] = workflow.batch_host if jobattrs[:host].nil?

    OSC::Machete::Job.new(jobattrs.merge(
      torque_helper: ResourceMgrAdapter.new
    ))
  end
end
