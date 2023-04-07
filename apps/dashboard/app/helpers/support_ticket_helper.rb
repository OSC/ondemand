# frozen_string_literal: true

# helper for the support ticket pages, email, and request tracker content.
module SupportTicketHelper
  def support_ticket_description_text
    @user_configuration.support_ticket[:description]
  end

  def filter_session_parameters(session_info)
    filter_parameters = [:ood_connection_info]
    session_info.to_h.reject { |key, _| filter_parameters.include?(key.to_sym) }
  end
end
