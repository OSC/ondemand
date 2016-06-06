require 'find'

class Workflow < ActiveRecord::Base
  has_many :jobs, class_name: "Job", dependent: :destroy
  has_machete_workflow_of :jobs

  # add accessors: [ :attr1, :attr2 ] etc. when you want to add getters and
  # setters to add new attributes stored in the JSON store
  # don't remove attributes from this list going forward! only deprecate
  store :job_attrs, coder: JSON

  attr_accessor :staging_template_dir

  # Name that defines the template/target dirs
  #def staging_template_name
  #  "workflows"
  #end

  # Override of osc_machete_rails
  # places jobs into the 'projects/default' folder
  def staging_target_dir_name
    "projects/default"
  end

  def staging_target_dir
    OodAppkit.dataroot.join(staging_target_dir_name)
  end

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

  # Get an array of all the files of a directory
  #
  # Find.find returns an enumerator - the first path is always the initial directory
  # so we return the array with the first item omitted
  def folder_contents
    File.directory?(staged_dir) ? Find.find(staged_dir).to_a[1..-1] : []
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
    new_workflow = Workflow.new
    new_workflow.name = self.name
    new_workflow.staging_template_dir = self.staged_dir
    new_workflow.batch_host = self.batch_host
    new_workflow.script_name = self.script_name
    new_workflow.staged_dir = new_workflow.stage.to_s
    new_workflow
  end

  # FIXME: replace with fix to osc-machete to not delete staged dir on failed submit
  #
  # - Set the workflow staged_dir at the beginning so other methods can use it
  # - Override Machete Workflow submit so that it doesn't delete the staged_dir
  #   when job submission fails
  def submit(template_view=self)
    self.staged_dir = stage   # set staged_dir
    render_mustache_files(staged_dir, template_view)
    after_stage(staged_dir)
    jobs = build_jobs(staged_dir)
    if submit_jobs(jobs)
      save_jobs(jobs, staged_dir)
    else
      # FileUtils.rm_rf staged_dir.to_s
      false
    end
  end
end
