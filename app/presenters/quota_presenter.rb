# Decorator for {Quota} object making it more presentable for the view
# Extend functionality of {Quota} object to describe if there are sufficient
# disk resources still available for the given volume
class QuotaPresenter < SimpleDelegator
  # Size of block in bytes
  BLOCK_SIZE = 1024

  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper

  # @param quota [Quota] the quota object we want to decorate
  # @param opts [#to_h] initialization options
  # @option opts [#to_f] :threshold threshold percentage
  def initialize(quota, opts = {})
    super(quota)

    opts = opts.to_h.compact.symbolize_keys
    @threshold = opts.fetch(:threshold, 0.9).to_f
  end

  # Threshold percentage that defines whether there are still sufficient disk
  # resources remaining
  # @return [Float] threshold percentage
  attr_reader :threshold

  # Whether there is sufficient disk space remaining under this volume
  # @return [Boolean] whether sufficient disk space remains
  def sufficient_blocks?
    total_block_usage < @threshold * block_limit
  end

  # Whether there is sufficient number of files remaining under this volume
  # @return [Boolean] whether sufficient number of files remains
  def sufficient_files?
    total_file_usage < @threshold * file_limit
  end

  # Whether there is sufficient disk resources remaining under this volume
  # @return [Boolean] whether sufficient disk resources remain
  def sufficient?
    sufficient_blocks? && sufficient_files?
  end

  # Whether there is an insufficient amount of any disk resource remaining for
  # this volume
  # @return [Boolean] whether volume has insufficient disk resources remaining
  def insufficient?
    ! sufficient?
  end

  # Human readable value for block usage
  # @return [String] block usage
  def human_user_block_usage
    number_to_human_size(user_block_usage * BLOCK_SIZE)
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
  def human_user_file_usage
    number_to_human(user_file_usage).downcase
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
  def human_user_resource_usage(resource)
    send "human_user_#{resource}_usage"
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
