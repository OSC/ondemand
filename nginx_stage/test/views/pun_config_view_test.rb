require 'test_helper'

class PunConfigViewTest < Minitest::Test
  include NginxStage::PunConfigView

  # required for generating the restart_confirmation in the PunConfigView module
  def app_init_url
    '/test'
  end

  def test_restart_confirmation_view
    expected = File.read('test/fixtures/restart_confirmation.html')
    assert_equal(expected, restart_confirmation)
  end
end
