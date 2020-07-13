require 'rspec'

class NavConfig
    class << self
      attr_accessor :categories, :show_only_specified_categories
      alias_method :show_only_specified_categories?, :show_only_specified_categories
      alias_method :categories_whitelist=, :show_only_specified_categories=
    end
    self.categories = ["Files", "Jobs", "Clusters", "Interactive Apps"]
    self.show_only_specified_categories = false
end

describe NavConfig do 
  it 'should have an inital value of false' do
    expect(NavConfig.show_only_specified_categories?).to eq(false)
  end

  context "show_only_specified_categories? is true" do
    it "if categories_whitelist is true" do 
        NavConfig.categories_whitelist=true
        expect(NavConfig.show_only_specified_categories?).to eq(true)
    end

    it "if show_only_specified_categories is true" do 
        NavConfig.show_only_specified_categories = true
        expect(NavConfig.show_only_specified_categories?).to eq(true)
    end
  end

  context "show_only_specified_categories? is false" do
    it "if categories_whitelist is false" do 
        NavConfig.categories_whitelist=false
        expect(NavConfig.show_only_specified_categories?).to eq(false)
    end

    it "if show_only_specified_categories is false" do 
        NavConfig.show_only_specified_categories = false
        expect(NavConfig.show_only_specified_categories?).to eq(false)
    end
  end
end

  
