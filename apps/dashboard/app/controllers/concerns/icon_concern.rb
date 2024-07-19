module IconConcern
  def icon_with_uri(icon)
    icon =~ /(fa[bsrl]?):\/\/(.*)/ || icon.nil? || icon.empty? ? icon : "fas://#{icon}"
  end
end