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
    OSC::Machete::Job.new(job_cache.symbolize_keys)
  end
end
