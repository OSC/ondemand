# Model class to hold the support ticket form data needed to submit a support ticket
#
class SupportTicket
  include ActiveModel::Model

  attr_accessor :username, :email, :cc, :subject, :session_id, :description, :attachments, :session
  validates :username, presence: { message: I18n.t('dashboard.support_ticket.validation.required.username') }
  validates :email, presence: { message: I18n.t('dashboard.support_ticket.validation.required.email') }
  validates :subject, presence: { message: I18n.t('dashboard.support_ticket.validation.required.subject') }
  validates :description, presence: { message: I18n.t('dashboard.support_ticket.validation.required.description') }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true, message: I18n.t('dashboard.support_ticket.validation.format.email') }
  validates :cc, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true, message: I18n.t('dashboard.support_ticket.validation.format.cc') }
  validates :attachments, attachments: true

  def initialize(attributes={})
    super
  end
end