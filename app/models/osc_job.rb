class OscJob < ActiveRecord::Base
  has_many :jobs, class_name: "OscJobJob", dependent: :destroy
  has_machete_workflow_of :jobs

  attr_accessor :name, :batch_host, :script_path

  # Name that defines the template/target dirs
  def staging_template_name
    "osc_job"
  end

  def staged_script_name
    # TODO allow set this to something else
    File.basename(self.script_path)
  end

  def staging_template_dir
    File.dirname(self.script_path)
  end

  def folder_contents
    dir = staged_dir || Dir.home
    Dir.glob("#{dir}/*").sort
  end

  # Define tasks to do after staging template directory typically copy over
  # uploaded files here
  # def after_stage(staged_dir)
  #   # CODE HERE
  # end

  # Build an array of Machete jobs that are then submitted to the batch server
  def build_jobs(staged_dir, job_list = [])
    job_list << OSC::Machete::Job.new(script: staged_dir.join(staged_script_name))
  end

  # Make copy of workflow
  def copy
    self.dup
  end

end
