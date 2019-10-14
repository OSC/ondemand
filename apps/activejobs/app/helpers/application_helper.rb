module ApplicationHelper

  def status_label(status)
    case status
    when "completed"
      label = "Completed"
      labelclass = "label-success"
    when "running"
      label = "Running"
      labelclass = "label-primary"
    when "queued"
      label = "Queued"
      labelclass = "label-info"
    when "queued_held"
      label = "Hold"
      labelclass = "label-warning"
    when "suspended"
      label = "Suspend"
      labelclass = "label-warning"
    else
      label = "Undetermined"
      labelclass = "label-default"
    end
    "<div style='white-space: nowrap;'><span class='label #{labelclass}'>#{label}</span></div>".html_safe
  end
end
