class OodAppLink
  attr_reader :title
  attr_reader :description
  attr_reader :url
  attr_reader :icon_uri
  attr_reader :caption
  attr_reader :nick_name

  def initialize(config = {})
    config = config.to_h.compact.symbolize_keys

    @title       = config.fetch(:title, "No title set").to_s
    @nick_name   = config.fetch(:nick_name, "No name").to_s
    @description = config.fetch(:description, "").to_s
    @url         = config.fetch(:url, "").to_s
    @icon_uri    = URI(config.fetch(:icon_uri, "fas://cog").to_s)
    @caption     = config.fetch(:caption, nil)
    @new_tab     = !!config.fetch(:new_tab, true)
  end

  def new_tab?
    @new_tab
  end
end

