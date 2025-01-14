require "test_helper"

class WidgetsControllerTest < ActiveSupport::TestCase

  def setup
    @controller = WidgetsController.new
  end

  test 'valid_path? validates widget paths' do
    refute @controller.send(:valid_path?, '/test!')
    refute @controller.send(:valid_path?, '/test/../../outside_dir')
    refute @controller.send(:valid_path?, '@user:pwd/dir')

    assert @controller.send(:valid_path?, 'test')
    assert @controller.send(:valid_path?, '/test')
    assert @controller.send(:valid_path?, '/test/path/widget')
    assert @controller.send(:valid_path?, '/test_path/widget')
    assert @controller.send(:valid_path?, '/test-path/widget_under/name')
  end

  test 'show should return HTTP 400 when invalid widget path is used' do
    @params = ActionController::Parameters.new({ widget_path: '!!invalid' })
    @controller.stubs(:params).returns(@params)
    @controller.expects(:render).with(plain: '400 Bad Request. Invalid widget path: /widgets/!!invalid', status: :bad_request)

    @controller.show
  end

  test 'show should return HTTP 404 when valid widget path is not found in the system' do
    @params = ActionController::Parameters.new({ widget_path: '/valid/path' })
    @controller.stubs(:params).returns(@params)
    @controller.expects(:render).with(plain: '404 Widget not found: /widgets/valid/path', status: :not_found)

    @controller.show
  end

  test 'show should render widget when valid widget path is found in the system' do
    @params = ActionController::Parameters.new({ widget_path: '/valid/path' })
    @controller.stubs(:params).returns(@params)
    @controller.lookup_context.stubs(:exists?).returns(true)
    @controller.expects(:render).with(partial: '/widgets/valid/path', layout: false)

    @controller.show
  end
end
