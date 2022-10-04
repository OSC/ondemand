require "test_helper"

class SupportTicketControllerTest < ActiveSupport::TestCase

  def setup
    @params = ActionController::Parameters.new({
       support_ticket: {
         email: "test@support.com",
         subject: "support ticket subject",
         description: "support ticket description",
       }
    })
    @controller = SupportTicketController.new
    @controller.stubs(:flash).returns(ActionDispatch::Request.empty.flash)
    @controller.stubs(:params).returns(@params)
    @controller.stubs(:render)
    @controller.stubs(:root_url).returns("/home")
  end

  test "get_ui_template returns default template when no override is configured" do
    template = @controller.send(:get_ui_template)
    assert_equal "email_service_template", template
  end

  test "get_ui_template returns template override when configured" do
    Configuration.stubs(:support_ticket_config).returns({ui_template: "template_override"})
    template = @controller.send(:get_ui_template)
    assert_equal "template_override", template
  end

  test "create_service_class returns SupportTicketEmailService when email configuration object defined" do
    # Configure the SupportTicketEmailService
    Configuration.stubs(:support_ticket_config).returns({email: { }})
    service = @controller.send(:create_service_class)
    assert_equal "SupportTicketEmailService", service.class.name
  end

  test "create_service_class returns SupportTicketRtService when rt_api configuration object defined" do
    # Configure the SupportTicketRtService
    Configuration.stubs(:support_ticket_config).returns({rt_api: { }})
    service = @controller.send(:create_service_class)
    assert_equal "SupportTicketRtService", service.class.name
  end

  test "create_service_class throws exception when no service class configured" do
    Configuration.stubs(:support_ticket_config).returns({})
    assert_raise StandardError do
      @controller.send(:create_service_class)
    end
  end

  test "new should render the default template when no override configured" do
    Configuration.stubs(:support_ticket_config).returns({email: { }})
    @controller.expects(:render).with() {|template| assert_equal "email_service_template", template}

    @controller.new
  end

  test "new should render the template override when configured" do
    Configuration.stubs(:support_ticket_config).returns({ui_template: "template_override", email: { }})
    @controller.expects(:render).with() {|template| assert_equal "template_override", template}

    @controller.new
  end

  test "new should delegate to service class default_support_ticket method with request params to create @support_ticket" do
    # Configure the SupportTicketEmailService
    Configuration.stubs(:support_ticket_config).returns({email: { }})
    expected_request_params = {test: "value"}
    @controller.stubs(:params).returns(expected_request_params)
    support_ticket_mock = stub()
    SupportTicketEmailService.any_instance.stubs(:default_support_ticket).with(expected_request_params).returns(support_ticket_mock)

    @controller.new
    assert_equal support_ticket_mock, @controller.instance_variable_get(:@support_ticket)
  end

  test "create should delegate to service class to validate and create ticket, then redirect to homepage" do
    # Configure the SupportTicketEmailService
    Configuration.stubs(:support_ticket_config).returns({email: { }})
    # Stub a valid support ticket
    support_ticket_stub = stub("support_ticket", {errors: []})
    # We expect the service to validate the request data
    SupportTicketEmailService.any_instance.stubs(:validate_support_ticket).returns(support_ticket_stub)
    # We expect the service to deliver the support ticket
    SupportTicketEmailService.any_instance.stubs(:deliver_support_ticket).returns("support ticket message")

    @controller.expects(:redirect_to).with("/home", {:flash => {:notice => "support ticket message"}})

    @controller.create
  end

  test "create should delegate to service class validate_support_ticket method and render support ticket template when validation fails" do
    # Configure the SupportTicketEmailService
    Configuration.stubs(:support_ticket_config).returns({email: { }})
    # Stub a support ticket with errors
    support_ticket_stub = stub("support_ticket", {errors: ["not_empty"]})
    SupportTicketEmailService.any_instance.stubs(:validate_support_ticket).returns(support_ticket_stub)

    flash_data = {}
    flash_stub = stub("flash").tap {|s| s.expects(:now).returns(flash_data)}
    @controller.stubs(:flash).returns(flash_stub)
    @controller.expects(:render).with("email_service_template")
    @controller.expects(:t).with('dashboard.support_ticket.validation_error')
    @controller.create

    assert_equal true, flash_data.key?(:alert)
  end

  test "create should log error and render the support ticket template when exception is raised" do
    # Configure the SupportTicketEmailService
    Configuration.stubs(:support_ticket_config).returns({email: { }})
    SupportTicketEmailService.any_instance.stubs(:validate_support_ticket).raises(StandardError, "General Error")

    # We expect to log the error
    logger_stub = stub("logger").tap {|s| s.expects(:error)}
    # We expect to a message for the front-end
    flash_data = {}
    flash_stub = stub("flash").tap {|s| s.expects(:now).returns(flash_data)}
    @controller.stubs(:flash).returns(flash_stub)
    @controller.stubs(:logger).returns(logger_stub)
    @controller.expects(:render).with("email_service_template")
    @controller.expects(:t).with('dashboard.support_ticket.generic_error', anything).returns('localized error message')

    @controller.create

    assert_equal true, flash_data.key?(:alert)
    assert_equal 'localized error message', flash_data.fetch(:alert)
  end

end