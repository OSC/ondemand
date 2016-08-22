require 'test_helper'

class TemplateTest < ActiveSupport::TestCase
  setup do
    @template = Template.new('./test/test_templates/template_one')
    @template_bad = Template.new('./test/test_templates/template_two_broken')
  end

  # Verify the templates are loaded properly.
  test "valid_template" do
    assert_equal( @template.path.to_s, "./test/test_templates/template_one" )
    assert @template.path.exist?

    assert_equal( @template_bad.path.to_s, "./test/test_templates/template_two_broken" )
    assert @template_bad.path.exist?
  end

  test "can_create_template" do
    assert_nothing_raised { Template.new('./test/test_templates/template_one') }
  end

end
