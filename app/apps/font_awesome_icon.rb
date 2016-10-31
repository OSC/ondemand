class FontAwesomeIcon
  attr_reader :icon

  def initialize(uristr)
    @icon = icon_for_uri(uristr)
  end

  def default_icon
    "gear"
  end

  def icon_for_uri(uristr)
    uri = URI.parse(uristr)

    if uri.scheme == "fa"
      uri.host
    else
      default_icon
    end
  rescue
    default_icon
  end

  def path
    nil
  end

  def file?
    false
  end

  def html
    %Q( <i class="fa fa-#{icon} app-icon"></i>).html_safe
  end
end
