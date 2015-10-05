module ApplicationHelper

  def username(attribs_Job_Owner)
    attribs_Job_Owner.split('@')[0]
  end

  def hostname(attribs_submit_host)
    attribs_submit_host.split(/\d+/)[0].capitalize

    # We may want to split after the number.
    # PBS returns jobs running  on Websvcs and N000 nodes,
    # and the above line cuts the digits.
    #attribs_submit_host.split('.')[0].capitalize
  end
end
