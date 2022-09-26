# Support ticket attachment validator
# Checks the number of files and the size are within the configured limits
# Defaults: 4 attachments and 6MB each
class AttachmentsValidator < ActiveModel::EachValidator
  # Common file sizes
  # 2MB = 2097152
  # 5MB = 5242880
  # 6MB = 6291456
  # 10MB = 10485760
  def self.restrictions
    @@restrictions ||= {}.tap do |hash|
      config = ::Configuration.support_ticket_config.fetch(:attachments, {})
      hash[:max_items] = config.fetch(:max_items, 4)
      hash[:max_size] = config.fetch(:max_size, 6291456)
    end
  end

  def validate_each(record, attribute, value)
    if value.blank?
      # Attachments are optional
      return
    end

    if value.size > AttachmentsValidator.restrictions[:max_items]
      record.errors.add attribute, I18n.t('dashboard.support_ticket.validation.items.attachments', items: value.size, max: AttachmentsValidator.restrictions[:items])
      return
    end

    value.each do |attachment|
      if attachment.size > AttachmentsValidator.restrictions[:max_size]
        record.errors.add attribute, I18n.t('dashboard.support_ticket.validation.size.attachments', max: size_to_string(AttachmentsValidator.restrictions[:max_size]))
        return
      end
    end
  end

  private

  # Human readable string for the file size
  def size_to_string(size)
    if size < 1024
      "#{size}bytes"
    elsif size >= 1024 && size < 1048576
      "%.1fKB" % (size/1024).round(1)
    elsif size >= 1048576
      "%.1fMB" % (size/1048576).round(1)
    end
  end
end