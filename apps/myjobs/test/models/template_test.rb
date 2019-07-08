require 'test_helper'

class TemplateTest < ActiveSupport::TestCase
  setup do
    @template = Template.new('./test/test_templates/template_one')
    @template_bad = Template.new('./test/test_templates/template_two_broken')
  end

  # Verify the templates are loaded properly.
  test "valid_template" do
    assert_equal File.expand_path("./test/test_templates/template_one"), @template.path.to_s
    assert @template.path.exist?

    assert_equal File.expand_path("./test/test_templates/template_two_broken"), @template_bad.path.to_s
    assert @template_bad.path.exist?
  end

  test "can_create_template" do
    assert_nothing_raised { Template.new('./test/test_templates/template_one') }
  end

  test "valid_manifest" do
    assert_kind_of( Manifest, @template.manifest )
  end

  test "malformed_manifest" do
    assert_kind_of( Manifest, @template_bad.manifest )
  end

end
