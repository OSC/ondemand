# frozen_string_literal: true

require 'test_helper'

class AppHelperTest < ActionView::TestCase
  test 'recent_settings escapes label and value to prevent XSS' do
    attrib = stub(
      display?: true,
      label:    '<script>alert("xss")</script>',
      value:    '"><img src=x onerror=alert(1)>'
    )
    app = stub(attributes: [attrib])

    result = recent_settings(app)

    assert_not_nil(result)
    assert_no_match(/<script>/, result)
    assert_no_match(/<img/, result)
    assert_includes(result, '&lt;script&gt;')
    assert_includes(result, '&quot;')
  end

  test 'recent_settings returns nil when no displayable attributes' do
    app = stub(attributes: [stub(display?: false)])
    assert_nil(recent_settings(app))
  end

  test 'recent_settings returns nil when attributes list is empty' do
    app = stub(attributes: [])
    assert_nil(recent_settings(app))
  end

  test 'recent_settings renders safe label and value unchanged' do
    attr = stub(display?: true, label: 'Number of cores', value: '4')
    app = stub(attributes: [attr])

    result = recent_settings(app)

    assert_includes(result, 'Number of cores')
    assert_includes(result, '4')
  end
end
