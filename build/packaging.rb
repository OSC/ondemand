
require "time"

desc "Package OnDemand"
task :package => 'package:tar'

namespace :package do

  def version
    branch = `git rev-parse --abbrev-ref HEAD`

    if branch == "HEAD"
      tag = `git tag --points-at HEAD`
      throw StandardError, "In detached head state, but not on a tag" if tag.empty?
      version = tag
    else
      last_commit = `git rev-list --tags --max-count=1`.strip[0..6]
      last_commit_time_str =`git log -1 --format=%cd`
      last_commit_time = Time.parse(last_commit_time_str).strftime("%Y%m%d%H%M")

      version = "#{base_version}_#{last_commit_time}.git#{last_commit}"
    end
    version
  end

  def base_version
    `cat VERSION`.strip
  end

  def tar_file
    "packaging/#{version}.tar.gz"
  end

  def rpmbuild_src_dir
    "#{ENV['HOME']}/rpmbuild/SOURCES"
  end

  def spec_file
    'packaging/ondemand.spec'
  end

  def rpm_args
    args = " -bb"
    args << " -vv"
    args << " --define 'package_version #{version}'"
    args << " --define 'git_tag #{base_version}'"
    args << " --define 'scl_ondemand_core_gem_home /opt/ood/ondemand/root/usr/share/gems'"
    args << " --nodeps"

    args
  end

  def rpm_sources
    [ tar_file, 'packaging/ondemand-selinux.fc', 'packaging/ondemand-selinux.te' ]
  end

  desc "Package the source tar"
  task :tar do
    `which gtar 1>/dev/null 2>&1`
    if $?.success?
      tar = 'gtar'
    else
      tar = 'tar'
    end
    sh "git ls-files | #{tar} -c --transform 's,^,ondemand-#{version}/,' -T - | gzip > #{tar_file}"
  end

  desc "Package the rpm"
  task :rpm  => [:tar] do
    rpm_sources.each { |src| cp src, rpmbuild_src_dir }
    sh "rpmbuild #{rpm_args} #{spec_file}"
  end

end