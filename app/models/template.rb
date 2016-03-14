class Template < ActiveRecord::Base

  # If the template exists but has no id, treat is as one of the system templates.
  def system?
    id.nil?
  end

  # Provide the http path to the file manager
  def file_manager_path
    # Use File.join because URI.join does not respect relative urls
    # TODO: Refactor FileManager into an initializer or helper class.
    #       This will be used elsewhere and often.
    File.join(FileManager[:fs], path)
  end
end
