# helper for product pages.
module ScriptHelper
  def scripts_path
    project_scripts_path
  end

  def base(file_name)
    file_name.split('.').first
  end
end
