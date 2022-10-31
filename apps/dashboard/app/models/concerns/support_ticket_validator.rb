# frozen_string_literal: true

# Support ticket validator
# Validates all the support ticket attributes based on their metadata.
# Supported validations:
#  - required
#  - email
#  - attachments
module SupportTicketValidator
  # Common file sizes
  # 2MB = 2097152
  # 5MB = 5242880
  # 6MB = 6291456
  # 10MB = 10485760
  def self.restrictions
    @@restrictions ||= {}.tap do |hash|
      config = ::Configuration.support_ticket_config.fetch(:attachments, {})
      hash[:max_items] = config.fetch(:max_items, 4)
      hash[:max_size] = config.fetch(:max_size, 6_291_456)
    end
  end

  def support_ticket_validation
    @attributes.each do |attribute|
      validate_required(attribute) if attribute.required
      validate_email(attribute) if attribute.widget == 'email_field'
      validate_attachments(attribute) if attribute.widget == 'file_attachments'
    end
  end

  def validate_required(attribute)
    errors.add(attribute.id, I18n.t('dashboard.support_ticket.validation.required', id: attribute.id)) if attribute.value.blank?
  end

  def validate_email(attribute)
    errors.add(attribute.id, I18n.t('dashboard.support_ticket.validation.email', id: attribute.id)) if !attribute.value.blank? && !URI::MailTo::EMAIL_REGEXP.match?(attribute.value)
  end

  def validate_attachments(attribute)
    if attribute.value.blank?
      # Attachments are optional
      return
    end

    if attribute.value.size > SupportTicketValidator.restrictions[:max_items]
      errors.add(attribute.id, I18n.t('dashboard.support_ticket.validation.attachments_items', id: attribute.id, items: attribute.value.size, max: SupportTicketValidator.restrictions[:max_items]))
      return
    end

    attribute.value.each do |attachment|
      next unless attachment.size > SupportTicketValidator.restrictions[:max_size]

      errors.add(attribute.id, I18n.t('dashboard.support_ticket.validation.attachments_size', id: attribute.id, max: size_to_string(SupportTicketValidator.restrictions[:max_size])))
      return
    end
  end

  private

  # Human readable string for the file size
  def size_to_string(size)
    ::ApplicationController.helpers.number_to_human_size(size, precision: 1, significant: false, strip_insignificant_zeros: false)
  end
end
