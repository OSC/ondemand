class OscJobJob < ActiveRecord::Base
  include OscMacheteRails::Statusable

  belongs_to :osc_job

  # Determine if the results are valid
  # def results_valid?
  #   # CODE GOES HERE
  # end
end
