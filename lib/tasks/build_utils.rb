# frozen_string_literal: true

module BuildUtils
  def proj_root
    File.expand_path(File.join(File.dirname(__FILE__), '../..'))
  end

  def image_tag
    tag? ? numeric_tag : "#{numeric_tag}-#{git_hash}"
  end

  def ood_version
    tag? ? git_tag : "#{git_tag}-#{git_hash}"
  end

  def git_hash
    @git_hash ||= `git rev-parse HEAD`.strip[0..6]
  end

  def git_tag
    @git_tag ||= `git describe --tags --abbrev=0`.chomp
  end

  def numeric_tag
    @numeric_tag ||= git_tag.delete_prefix('v')
  end

  def tag?
    @tag ||= `git describe --exact-match --tags HEAD 2>/dev/null`.to_s != ""
  end

  def podman_runtime?
    @podman_runtime ||= ENV['CONTAINER_RT'] == "podman"
  end

  def container_runtime
    podman_runtime? ? "podman" : "docker"
  end

  def test_image_name
    "ood-test"
  end

  def dev_image_name
    "ood-dev"
  end

  def image_name
    "ood"
  end

  def user
    @user ||= Etc.getpwnam(Etc.getlogin)
  end
end