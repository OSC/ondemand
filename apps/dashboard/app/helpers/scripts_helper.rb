# helper for projects/script pages.
module ScriptsHelper
  def scripts_path
    project_scripts_path
  end

  def project_name
    @scripts.category.name
  end
end
