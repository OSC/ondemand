# OodAppLink is a representation of an HTML link to an OodApp.
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

  def to_h
    instance_variables.each_with_object({}) do |var, hash|
      hash[var.to_s.gsub('@', '').to_sym] = instance_variable_get(var)
    end
  end

  def categorize(category: nil, subcategory: nil)
    LinkCategorizer.new(self, category: category, subcategory: subcategory)
  end

  private

  # Decorate an OodAppLink to look like an OodApp so it can be recategorized
  # in the menus.
  class LinkCategorizer < SimpleDelegator
    attr_reader :category, :subcategory

    def initialize(link, category: nil, subcategory: nil)
      super(link)
      @category = category
      @subcategory = subcategory
    end

    def links
      [self]
    end

    def metadata
      {}
    end
  end
end

