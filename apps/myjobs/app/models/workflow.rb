require 'find'

class Workflow < ActiveRecord::Base
  has_many :jobs, class_name: "Job", dependent: :destroy
  has_machete_workflow_of :jobs
  before_create :stage_workflow

  # add accessors: [ :attr1, :attr2 ] etc. when you want to add getters and
  # setters to add new attributes stored in the JSON store
  # don't remove attributes from this list going forward! only deprecate
  store :job_attrs, coder: JSON, accessors: [:account, :job_array_request]

  attr_accessor :staging_template_dir

  # get all workflows that have active jobs
  scope :active, -> { joins(:jobs).merge(Job.active) }

  def update_status!
    jobs.to_a.each(&:update_status!)
  end

  # Name that defines the template/target dirs
  #def staging_template_name
  #  "workflows"
  #end

  # @param [Template] template A template to generate a workflow from
  # @return [Workflow] Return a new workflow based on the template
  def self.new_from_template(template)
    raise NotImplementedError if template.source.nil?

    workflow = Workflow.new
    workflow.name = template.manifest.name
    workflow.staging_template_dir = template.path
    workflow.batch_host = template.manifest.host
    workflow.script_name = template.manifest.script
    workflow
  end

  # Create a new workflow from a path and attempt to load a manifest on that path.
  #
  # @param [String] path A path to use as a non-static template
  # @return [Workflow] Return a new workflow based on the path
  def self.new_from_path(path)
    path = Pathname.new(path).expand_path rescue Pathname.new(path)
    workflow = Workflow.new
    workflow.name = ''
    workflow.batch_host = OODClusters.first.id
    workflow.script_name = ''
    workflow.staging_template_dir = path.to_s

    # Attempt to load a manifest on the path
    manifest_path = path.join('manifest.yml')
    if manifest_path.exist?
      manifest = Manifest.load manifest_path
      workflow.name = manifest.name
      workflow.batch_host = manifest.host
      workflow.script_name = manifest.script
    end
    workflow
  end

  # Override of osc_machete_rails
  # places jobs into the 'projects/default' folder
  def staging_target_dir_name
    "projects/default"
  end

  def staging_target_dir
    OodAppkit.dataroot.join(staging_target_dir_name)
  end

  def staged_dir_exists?
    staged_dir && File.directory?(staged_dir)
  end

  def staged_script_name
    self.script_name
  end

  def staged_script_exists?
    File.file? self.script_path
  end

  def script_path
    Pathname.new(self.staged_dir).join(self.script_name.to_s)
  end

  def script_path=(new_path)
    unless self.staged_dir.nil?
      path = Pathname.new(new_path)
      staged = Pathname.new(self.staged_dir)
      self.script_name = path.relative_path_from(staged).to_s
    end
  end

  # @return [Boolean] true if batch_host is assigned and exists in the OODClusters array
  def batch_host_exists?
    if self.batch_host
      if OODClusters[self.batch_host]
        return true
      end
    end
    return false
  end

  class StagingTemplateDirMissing < StandardError; end
  # Override of OSC::Machete#stage
  # Creates a new staging target job directory on the system
  # Copies the staging template directory to the staging target job directory
  #
  # @return [Pathname] The staged directory path.
  def stage
    if self.staged_dir.nil?
      raise StagingTemplateDirMissing unless staging_template_dir && File.directory?(staging_template_dir)

      self.staged_dir = OSC::Machete::JobDir.new(staging_target_dir).new_jobdir.to_s
      FileUtils.mkdir_p self.staged_dir

      # rsync to ignore manifest.yml
      stdout, stderr, status = Open3.capture3 "rsync -r --exclude='manifest.yml' #{Shellwords.escape(staging_template_dir.to_s)}/ #{Shellwords.escape(self.staged_dir)}"
      raise IOError if status.exitstatus != 0
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

  # Returns the pbsid of the last job in the workflow
  #
  # @return [String, nil] the pbsid or nil if no jobs on the workflow
  def pbsid
    jobs.last.pbsid unless jobs.last.nil?
  end

  # Returns the optional user-entered account string
  #
  # @return [String, nil] the account string or nil if blank
  def account
    super.strip unless super.blank?
  end

  # Define tasks to do after staging template directory typically copy over
  # uploaded files here
  # def after_stage(staged_dir)
  #   # CODE HERE
  # end

  # Build an array of Machete jobs that are then submitted to the batch server
  def build_jobs(staged_dir, job_list = [])
    job_list << OSC::Machete::Job.new(
      script: staged_dir.join(staged_script_name),
      host: batch_host,
      account_string: account,
      torque_helper: ResourceMgrAdapter.new(self)
    )
  end

  # Make copy of workflow
  def copy
    new_workflow = Workflow.new
    new_workflow.name = self.name
    new_workflow.staging_template_dir = self.staged_dir
    new_workflow.batch_host = self.batch_host
    new_workflow.script_name = self.script_name
    new_workflow.job_attrs = self.job_attrs
    new_workflow
  end

  # FIXME: replace with fix to osc-machete to not delete staged dir on failed submit
  #
  # - Set the workflow staged_dir at the beginning so other methods can use it
  # - Override Machete Workflow submit so that it doesn't delete the staged_dir
  #   when job submission fails
  def submit(template_view=self)
    success = false

    staged_dir = stage   # set staged_dir

    #FIXME: we should add to osc_machete a job directory missing exception
    if ! staged_dir.directory?
      errors[:base] << "Job directory is missing: #{staged_dir.to_s}"
    else
      render_mustache_files(staged_dir, template_view)
      after_stage(staged_dir)
      jobs = build_jobs(staged_dir)
      if submit_jobs(jobs)
        success = save_jobs(jobs, staged_dir)
      else
        # FIXME: we should let the developer disable removing the job directory
        # after a submission fails
        #
        # Don't remove the directory here
        # FileUtils.rm_rf staged_dir.to_s
      end
    end

    success
  end

  # Stops all jobs, updating each active job to status "failed"
  # returns true if all jobs were stopped, false otherwise
  def stop
    jobs_active_record_relation.to_a.each(&:stop)

    true
  rescue PBS::Error => e
    msg = "An error occurred when trying to stop jobs for simulation #{id}: #{e.message}"
    errors[:base] << msg
    Rails.logger.error(msg)

    false
  end

  # Call the #submit method on each job in a hash.
  #
  # @param [Hash] jobs A Hash of Job objects to be submitted.
  def submit_jobs(jobs)
    jobs.each(&:submit)
    true
  rescue OSC::Machete::Job::ScriptMissingError => e
    stop_machete_jobs(jobs)

    msg = "A OSC::Machete::Job::ScriptMissingError occurred when submitting jobs for simulation #{id}: #{e.message}"
    errors[:base] << msg
    Rails.logger.error(msg)
    false
  rescue PBS::Error => e
    stop_machete_jobs(jobs)

    msg = "An error occurred when submitting jobs for simulation #{id}: #{e.message}"
    errors[:base] << msg
    Rails.logger.error(msg)

    false
  end

  # given an array of OSC::Machete::Job objects, qdel them all and handle
  # any errors. not to be confused with #stop which stops all actual jobs of
  # the workflow
  def stop_machete_jobs(jobs)
    jobs.each do |job|
      begin
        job.delete
      rescue PBS::Error
        msg = "An error occurred when deleting a job from the batch system with pbsid: #{job.pbsid} and message: #{e.message}"
        errors[:base] << msg
        Rails.logger.error(msg)
      end
    end
  end

  def self.show_job_arrays?
    OODClusters.any? { |cluster| cluster.job_adapter.supports_job_arrays? }
  end

  def self.not_all_clusters_support_job_arrays
    OODClusters.any? { |cluster| ! cluster.job_adapter.supports_job_arrays? }
  end

  def self.clusters_not_supporting_job_arrays
    OODClusters.reject {
      |cluster| cluster.job_adapter.supports_job_arrays?
    }.map {
      |cluster| "#{cluster.metadata.title || cluster.id.titleize} (#{cluster.job_config[:adapter].titleize})"
    }
  end

  private

    def stage_workflow
      begin
        stage
      rescue
        self.errors[:base] << "Cannot stage job because of an error copying the folder, check that you have adequate read permissions to the source folder and that the source folder exists."
        return false
      end
    end
end
