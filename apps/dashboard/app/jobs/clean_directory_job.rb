# frozen_string_literal: true

# Job class for removing a directory.
class CleanDirectoryJob < ApplicationJob
  queue_as :default

  def perform(dir)
    return unless File.directory?(dir) && File.writable?(dir) && File.executable?(dir)

    begin
      FileUtils.rm_r(dir)
    rescue StandardError => e
      Rails.logger.warn("Could not remove #{dir} because of error #{e.class}:#{e.message}")
    end
  end
end
