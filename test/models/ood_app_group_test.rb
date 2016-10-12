require 'test_helper'

class OodAppGroupTest < ActiveSupport::TestCase

  test "app groups split by group's specified by apps" do
    g = OodAppGroup.new
    g.title = "Default"
    g.subtitle = "efranz"

    # add apps
    2.times { g.apps << OpenStruct.new(group: nil) }
    3.times { g.apps << OpenStruct.new(group: "") }
    g.apps << OpenStruct.new(group: "Company A")
    3.times { g.apps << OpenStruct.new(group: "Company B") }
    4.times { g.apps << OpenStruct.new(group: "Company C") }

    groups = g.split
    groups = groups.sort_by { |g| g.title }

    # now we should have groups with these titles in this order
    # [Company A, "Company B", Company C, Default]

    assert_equal 4, groups.count, 'apps with nil and "" groups should be grouped together '
    assert_equal "Company A", groups.first.title
    assert_equal "efranz", groups.first.subtitle
    assert_equal 1, groups.first.apps.count

    assert_equal "Default", groups.last.title
    assert_equal "efranz", groups.last.subtitle
    assert_equal 5, groups.last.apps.count
  end
end
