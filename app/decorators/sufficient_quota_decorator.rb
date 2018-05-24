# Extend functionality of {Quota} object to describe if there are sufficient
# disk resources still available for the given volume
class SufficientQuotaDecorator < SimpleDelegator
  # Threshold percentage that defines whether there are still sufficient disk
  # resources remaining
  # @return [Float] threshold percentage
  attr_reader :threshold

  # @param quota [Quota] the quota object we want to decorate
  # @param opts [#to_h] initialization options
  # @option opts [#to_f] :threshold threshold percentage
  def initialize(quota, opts = {})
    super(quota)

    opts = opts.to_h.compact.symbolize_keys
    @threshold = opts.fetch(:threshold, Configuration.quota_threshold).to_f
  end

  # Whether there is sufficient disk space remaining under this volume
  # @return [Boolean] whether sufficient disk space remains
  def sufficient_blocks?
    total_block_usage < threshold * block_limit
  end

  # Whether there is sufficient number of files remaining under this volume
  # @return [Boolean] whether sufficient number of files remains
  def sufficient_files?
    total_file_usage < threshold * file_limit
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
end
