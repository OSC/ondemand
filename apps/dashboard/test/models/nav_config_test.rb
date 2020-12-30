require 'test_helper'
require_relative '../../app/apps/nav_config'

class NavConfigTest < ActiveSupport::TestCase
    def setup
        NavConfig.categories = ["Files", "Jobs", "Clusters", "Interactive Apps"]
        NavConfig.show_only_specified_categories = false
    end

    test 'inital value of show_only_specified_categories? is false' do
        assert_equal(false, NavConfig.show_only_specified_categories?)
    end

    test 'show_only_specified_categories? true if categories_whitelist is true' do
        NavConfig.categories_whitelist = true
        assert_equal(NavConfig.show_only_specified_categories?, true)
    end

    test 'show_only_specified_categories? true if show_only_specified_categories is true' do 
        NavConfig.show_only_specified_categories = true
        assert_equal(NavConfig.show_only_specified_categories?, true)
    end

    test 'show_only_specified_categories? false if categories_whitelist is false' do
        NavConfig.categories_whitelist = false
        assert_equal(NavConfig.show_only_specified_categories?, false)
    end
 
    test 'show_only_specified_categories? false if show_only_specified_categories is false' do 
        NavConfig.show_only_specified_categories = false
        assert_equal(NavConfig.show_only_specified_categories?, false)
    end

    def teardown
        NavConfig.categories = ["Files", "Jobs", "Clusters", "Interactive Apps"]
        NavConfig.show_only_specified_categories = false
    end
end
