# A simple subclass of OodApp that overrides category
# and subcategory to allow for groupings other than what's
# provided in the app's manifest & definition.
class FeaturedApp < OodApp
  attr_reader :category, :subcategory

  def initialize(router, category: "Apps", subcategory: "Pinned Apps")
    super(router)
    @category = category.to_s
    @subcategory = subcategory.to_s
  end
end
