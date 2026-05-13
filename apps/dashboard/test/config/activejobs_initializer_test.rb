require 'test_helper'

class ActivejobsInitializerTest < ActiveSupport::TestCase
  test 'activejobs initializer rejects metadata.hidden clusters like ApplicationHelper#clusters' do
    code = Rails.root.join('config/initializers/activejobs.rb').read
    assert_match(/allow\?\).*\.reject\s*\{\s*\|c\|\s*c\.metadata\.hidden\s*\}/m, code)
  end
end