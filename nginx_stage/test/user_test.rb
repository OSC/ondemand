require 'test_helper'


class UserTest < Minitest::Test
  include TestHelper

  def test_good_initialization
    stub_user('test')
    user = NginxStage::User.new('test')

    assert('test', user.name)
  end

  def test_username_differs_from_fullname
    stub_user('test@domain.edu')

    msg = <<~HEREDOC
      Username 'test' is being mapped to 'test@domain.edu' in SSSD and they don't match.
      Users with domain names cannot be mapped correctly. If 'test@domain.edu' still has the
      domain in it you'll need to set SSSD's full_name_format to '%1$s'.

      See https://github.com/OSC/ondemand/issues/1759 for more details.
    HEREDOC

    error = assert_raises(StandardError, 'Should have raised an error') do
      NginxStage::User.new('test')
    end
    assert_equal(msg, error.message)
  end
end
