module IconWithUri
  private

  def add_icon_uri
    @icon = @icon =~ /(fa[bsrl]?):\/\/(.*)/ || @icon.nil? || @icon.empty? ? @icon : "fas://#{@icon}"
  end
end