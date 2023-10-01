# frozen_string_literal: true

class RenameOscJobJobToJob < ActiveRecord::Migration[4.2]
  def change
    rename_table :osc_job_jobs, :jobs
  end
end
