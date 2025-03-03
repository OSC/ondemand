class  ProjectManifest < Manifest
  def files
    manifest_options[:files] || []
  end
end