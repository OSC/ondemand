# frozen_string_literal: true

# Emailer class responsible to send support ticket emails
# It supports emailer settings in standard Rails configuration
# or provided in the support_ticket configuration object.
class SupportTicketMailer < ActionMailer::Base
  helper :support_ticket
  default template_path: ['support_ticket/email']
  default template_name: 'email_layout'

  def support_email(support_ticket_config, context)
    @context = context

    unless @context.support_ticket.attachments.blank?
      @context.support_ticket.attachments.to_a.each do |request_file|
        attachments[request_file.original_filename] = File.read(request_file.tempfile)
      end
    end

    email_service_config = support_ticket_config.fetch(:email, {})

    mail_data = {}.tap do |settings|
      settings[:from] = email_service_config.fetch(:from, @context.support_ticket.email)
      settings[:reply_to] = @context.support_ticket.email
      settings[:to] = email_service_config.fetch(:to)
      settings[:cc] = @context.support_ticket.cc
      settings[:subject] = @context.support_ticket.subject

      # Override Rails delivery settings with support ticket configuration if provided
      # This will allow admins to use standard Rails configuration settings if required.
      if email_service_config[:delivery_method]
        settings[:delivery_method] =
          email_service_config[:delivery_method].to_sym
      end
      if email_service_config[:delivery_settings]
        settings[:delivery_method_options] =
          email_service_config[:delivery_settings]
      end
    end

    mail(mail_data)
  end
end
