# frozen_string_literal: true

require 'beaker'
require 'beaker/hypervisor/docker'

# Helpers for the end-to-end tests that patch their test tooling.
module OodE2E
  # beaker-docker builds each test image without telling Docker which platform
  # it wants, so Docker resolves the FROM line against the runner's platform.
  # The ppc64le nodesets run on x86_64 runners under QEMU, and their base images
  # only publish linux/ppc64le, so that lookup fails with "no matching manifest
  # for linux/amd64". A nodeset host that sets docker_platform (for example
  # linux/ppc64le) has its image built for that platform instead.
  #
  # This has to be loaded before beaker-rspec, which provisions hosts as soon
  # as it is required.
  module BeakerDockerPlatform
    def get_container_image(host)
      platform = host['docker_platform'].to_s
      return super if platform.empty?

      if host['dockerfile'] || host['use_image_as_is'] || host['use_image_entry_point']
        raise ArgumentError,
              "docker_platform only supports Beaker's generated Dockerfile, not dockerfile, " \
              'use_image_as_is or use_image_entry_point'
      end

      @logger.debug("Creating image for #{platform}")
      ::Docker::Image.build(dockerfile_for(host), { rm: true, buildargs: buildargs_for(host), platform: platform })
    end
  end
end

Beaker::Docker.prepend(OodE2E::BeakerDockerPlatform)
