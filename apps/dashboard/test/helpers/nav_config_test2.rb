require 'minitest/autorun'
require './../../app/apps/nav_config.rb' #wrong path so class is below

class NavConfig
    class << self
      attr_accessor :categories, :show_only_specified_categories
      alias_method :show_only_specified_categories?, :show_only_specified_categories
      alias_method :categories_whitelist=, :show_only_specified_categories=
    end
    self.categories = ["Files", "Jobs", "Clusters", "Interactive Apps"]
    self.show_only_specified_categories = false
end

class NavConfigTest < Minitest::Test
    def test_inital_value_of_false
      assert_equal(NavConfig.show_only_specified_categories?, false)
    end

    def test_specified_categories_true_if_categories_whitelist_is_true
        NavConfig.categories_whitelist = true
        assert_equal(NavConfig.show_only_specified_categories?, true)
    end

    def test_specified_categories_true_if_show_only_speficied_categories_is_true
        NavConfig.show_only_specified_categories = true
        assert_equal(NavConfig.show_only_specified_categories?, true)
    end


    def test_specified_categories_false_if_categories_whitelist_is_false
        NavConfig.categories_whitelist = false
        assert_equal(NavConfig.show_only_specified_categories?, false)
    end

    def test_specified_categories_false_if_show_only_speficied_categories_is_false
        NavConfig.show_only_specified_categories = false
        assert_equal(NavConfig.show_only_specified_categories?, false)
    end
end
