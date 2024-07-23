module IconWithUri
  private

  def add_icon_uri
    if @icon.nil? || @icon.empty?
      @icon = 'fas://cog'
    elsif @icon !~ /(fa[bsrl]?):\/\/(.*)/
      @icon = "fas://#{icon}"
    end
    @icon = @icon =~ /(fa[bsrl]?):\/\/(.*)/ || @icon.nil? || @icon.empty? ? @icon : "fas://#{@icon}"
  end
end