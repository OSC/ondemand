module ApplicationHelper
  def username(attribs_Job_Owner)
    attribs_Job_Owner.split('@')[0]
  end

  def hostname(attribs_submit_host)
    #attribs_submit_host.split(/\d+/)[0]

    # We may want to split after the number.
    # PBS returns jobs running  on Websvcs and N000 nodes,
    # and the above line cuts the digits and not the number.
    # Additional handling will be necessary if we want
    # to avoid displaying 'oakley02', 'ruby01', etc.
    attribs_submit_host.split('.')[0]
  end

  def status_label(attribs_job_state)
    case attribs_job_state
      when "C"
        label = "Completed"
        labelclass = "label-success"
      when "R"
        label = "Running"
        labelclass = "label-primary"
      when "Q"
        label = "Queued"
        labelclass = "label-info"
      when "H"
        label = "Hold"
        labelclass = "label-warning"
      when "E"
        label = "Exiting"
        labelclass = "label-info"
      when "S"
        label = "Suspend"
        labelclass = "label-warning"
      when "T"
        label = "Transiting"
        labelclass = "label-warning"
      when "W"
        label = "Waiting"
        labelclass = "label-info"
      else
        label = "Not Submitted"
        labelclass = "label-default"
    end
    "<span class='label #{labelclass}'>#{label}</span>".html_safe
  end
end