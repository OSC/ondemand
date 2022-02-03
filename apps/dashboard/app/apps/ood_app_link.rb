class OodAppLink
  attr_reader :title
  attr_reader :description
  attr_reader :url
  attr_reader :icon_uri
  attr_reader :caption
  attr_reader :subtitle
  attr_reader :data

  def initialize(config = {})
    config = config.to_h.compact.symbolize_keys

    @title       = config.fetch(:title, "").to_s
    @subtitle   = config.fetch(:subtitle, "").to_s
    @description = config.fetch(:description, "").to_s
    @url         = config.fetch(:url, "").to_s
    @icon_uri    = URI(config.fetch(:icon_uri, "fas://cog").to_s)
    @caption     = config.fetch(:caption, nil)
    @new_tab     = !!config.fetch(:new_tab, true)
    @data        = config.fetch(:data, {}).to_h
  end

  def new_tab?
    @new_tab
  end
end

