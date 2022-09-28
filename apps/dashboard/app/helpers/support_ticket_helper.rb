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

end