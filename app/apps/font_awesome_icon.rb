class FontAwesomeIcon
  attr_reader :icon

  DEFAULT="gear"
  DEFAULT_URI_STR="fa://gear"

  def initialize(uristr)
    @icon = icon_for_uri(uristr)
  end

  def icon_for_uri(uristr)
    uri = URI.parse(uristr)

    if uri.scheme == "fa"
      uri.host
    else
      FontAwesomeIcon::DEFAULT
    end
  rescue
    FontAwesomeIcon::DEFAULT
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
