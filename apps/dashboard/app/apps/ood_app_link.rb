# frozen_string_literal: true

# OodAppLink is a representation of an HTML link to an OodApp.
class OodAppLink
  attr_reader :title, :description, :url, :icon_uri, :caption, :subtitle, :data, :tile

  def initialize(config = {})
    config = config.to_h.compact.symbolize_keys

    @title       = config.fetch(:title, '').to_s
    @subtitle    = config.fetch(:subtitle, '').to_s
    @description = config.fetch(:description, '').to_s
    @url         = config.fetch(:url, '').to_s
    @icon_uri    = URI(config.fetch(:icon_uri, 'fas://cog').to_s)
    @caption     = config.fetch(:caption, nil)
    @new_tab     = config.fetch(:new_tab, true)
    @data        = config.fetch(:data, {}).to_h
    @tile        = config.fetch(:tile, {}).to_h.deep_symbolize_keys
  end

  def new_tab?
    @new_tab
  end

  def to_h
    instance_variables.each_with_object({}) do |var, hash|
      hash[var.to_s.gsub('@', '').to_sym] = instance_variable_get(var)
    end
  end

  def categorize(category: '', subcategory: '', show_in_menu: false)
    LinkCategorizer.new(self, category: category, subcategory: subcategory, show_in_menu: show_in_menu)
  end

  # Decorate an OodAppLink to look like an OodApp so it can be recategorized
  # in the menus.
  class LinkCategorizer < SimpleDelegator
    attr_reader :category, :subcategory

    def initialize(link, category: '', subcategory: '', show_in_menu: false)
      super(link)
      @category = category
      @subcategory = subcategory
      @show_in_menu = show_in_menu
    end

    def links
      [self]
    end

    def show_in_menu?
      @show_in_menu
    end
  end
end
