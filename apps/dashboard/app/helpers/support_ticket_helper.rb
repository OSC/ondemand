# frozen_string_literal: true

# helper for the support ticket pages and the the backend implementations.
module SupportTicketHelper
  def support_ticket_description_text
    @user_configuration.support_ticket[:description]&.html_safe
  end

  def support_ticket_javascript
    js_file_config = @user_configuration.support_ticket[:javascript]
    return nil if js_file_config.blank?

    js_file_src = js_file_config.is_a?(Hash) ? js_file_config[:src].to_s : js_file_config.to_s
    js_file_type = js_file_config.is_a?(Hash) ? js_file_config[:type].to_s : ''
    return nil if js_file_src.blank?

    { src: File.join(@user_configuration.public_url, js_file_src), type: js_file_type }
  end

  def filter_session_parameters(session_info)
    filter_parameters = [:ood_connection_info]
    session_info.to_h.reject { |key, _| filter_parameters.include?(key.to_sym) }
  end
end
