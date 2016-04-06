require 'find'

class OscJob < ActiveRecord::Base
  has_many :jobs, class_name: "OscJobJob", dependent: :destroy
  has_machete_workflow_of :jobs

  attr_accessor :staging_template_dir

  # Name that defines the template/target dirs
  #def staging_template_name
  #  "osc_jobs"
  #end

  def staged_script_name
    self.script_name
  end

  def script_path
    Pathname.new(self.staged_dir).join(self.script_name)
  end

  def script_path=(new_path)
    unless self.staged_dir.nil?
      path = Pathname.new(new_path)
      staged = Pathname.new(self.staged_dir)
      self.script_name = path.relative_path_from(staged).to_s
    end
  end

  # Override of OSC::Machete#stage
  # Creates a new staging target job directory on the system
  # Copies the staging template directory to the staging target job directory
  #
  # @return [Pathname] The staged directory path.
  def stage
    unless self.staged_dir
      self.staged_dir = OSC::Machete::JobDir.new(staging_target_dir).new_jobdir
      FileUtils.mkdir_p self.staged_dir
      FileUtils.cp_r staging_template_dir.to_s + "/.", self.staged_dir
    end
    Pathname.new(self.staged_dir)
  end

  # def staging_template_dir
  #   File.dirname(self.script_path)
  # end

  def folder_contents
    dir = self.staged_dir || Dir.home
    file_paths = []
    Find.find(dir) do |path|
      file_paths << path unless path == dir
    end
    file_paths
  end

  def pbsid
    jobs.last.pbsid unless jobs.last.nil?
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
