# frozen_string_literal: true

require 'test_helper'

module BatchConnect
  class VncViewTest < ActiveSupport::TestCase
    test 'should have Windows VNC native instructions partial' do
      assert Rails.root.join('app/views/batch_connect/sessions/connections/_native_vnc_windows.html.erb').file?,
             '_native_vnc_windows.html.erb partial is required to exist so we can override it in /etc for OSC Connect directions'
    end
  end
end
