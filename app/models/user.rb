class User < OodSupport::User

  # other paths to provide links to via file explorer
  def other_paths
    @other_paths ||= Rails.application.config.x.ood.files_other_paths.select {|p|
      p.directory? && p.readable? && p.executable?
    }
  end
end
