# helper for the support ticket page
module SupportTicketHelper

  def support_ticket_add_error_class(field)
    "has-error" if support_ticket_has_error?(field)
  end

  def support_ticket_add_error_message(field)
    if support_ticket_has_error?(field)
      html = %Q(<div class="help-block" id="#{field}_error">#{@support_ticket.errors[field][0]}</div>)
      html.html_safe
    end
  end

  def support_ticket_has_error?(field)
    !@support_ticket.errors[field].blank?
  end

  def filter_session_parameters(session_info)
    filter_parameters = [:ood_connection_info]
    session_info.to_h.reject {|key, _| filter_parameters.include?(key.to_sym) }
  end

end