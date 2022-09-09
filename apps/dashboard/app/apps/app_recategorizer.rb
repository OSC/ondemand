# Wrapper around OodApp to override category and subcategory.
# This is to create artificial groups and subgroups for a custom navigation.
class AppRecategorizer < SimpleDelegator

  def initialize(ood_app, category: nil, subcategory: nil)
    super(ood_app)
    @inner_category = category
    @inner_subcategory = subcategory
  end

  def category
    inner_category
  end

  def subcategory
    inner_subcategory
  end

  private

  attr_reader :inner_category, :inner_subcategory
end