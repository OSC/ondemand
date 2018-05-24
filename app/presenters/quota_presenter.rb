# Decorator for {Quota} object making it more presentable for the view
class QuotaPresenter < SimpleDelegator
  # Size of block in bytes
  BLOCK_SIZE = 1024

  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper

  # Human readable value for block usage
  # @return [String] block usage
  def human_block_usage
    number_to_human_size(block_usage * BLOCK_SIZE)
  end

  # Human readable value for total block usage
  # @return [String] total block usage
  def human_total_block_usage
    number_to_human_size(total_block_usage * BLOCK_SIZE)
  end

  # Human readable value for block limit
  # @return [String] block limit
  def human_block_limit
    number_to_human_size(block_limit * BLOCK_SIZE)
  end

  # Percent of total blocks used for this volume
  # @return [Integer] percent total block usage
  def total_block_usage_percent
    total_block_usage * 100 / block_limit
  end

  # Human readable value for file usage
  # @return [String] file usage
  def human_file_usage
    number_to_human(file_usage).downcase
  end

  # Human readable value for total file usage
  # @return [String] total file usage
  def human_total_file_usage
    number_to_human(total_file_usage).downcase
  end

  # Human readable value for file limit
  # @return [String] file limit
  def human_file_limit
    number_to_human(file_limit).downcase
  end

  # Percent of total files used for this volume
  # @return [Integer] percent total file usage
  def total_file_usage_percent
    total_file_usage * 100 / file_limit
  end

  # Human readable value for requested resource usage
  # @return [String] requested resource usage
  def human_resource_usage(resource)
    send "human_#{resource}_usage"
  end

  # Human readable value for total requested resource usage
  # @return [String] total requested resource usage
  def human_total_resource_usage(resource)
    send "human_total_#{resource}_usage"
  end

  # Human readable value for requested resource limit
  # @return [String] requested resource limit
  def human_resource_limit(resource)
    send "human_#{resource}_limit"
  end

  # Percent of total requested resource used for this volume
  # @return [Integer] percent total requested resource usage
  def total_resource_usage_percent(resource)
    send "total_#{resource}_usage_percent"
  end

  # Human readable distance in time when quota object was last generated
  # @return [String] how long ago last updated
  def last_updated_ago
    time_ago_in_words(updated_at)
  end

  # The url for the volume
  # @return [String] url of volume
  def url
    OodAppkit.files.url(path: path).to_s
  end
end
