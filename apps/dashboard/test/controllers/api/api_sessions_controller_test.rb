require 'test_helper'


class Api::ApiSessionsControllerTest < ActionController::TestCase

  # ENV['OOD_BATCH_CONNECT_API_ENABLED'] NEEDS TO BE ENABLED => config/environments/test

  test ":index should return :internal_server_error when Session throws error" do
    BatchConnect::Session.stubs(:all).raises(Exception, 'error')
    get :index
    assert_response :internal_server_error
  end

  test ":show should return :not_found when session_id does not exists" do
    BatchConnect::Session.stubs(:exist?).returns(false)
    get :show, params: { id: '12345' }
    assert_response :not_found
  end

  test ":show should return session information when session_id exists" do
    BatchConnect::Session.stubs(:exist?).returns(true)
    BatchConnect::Session.stubs(:find).returns(mock("session"))
    @controller.stubs(:create_session_data).returns({})

    get :show, params: { id: '12345' }
    assert_response :ok
    assert_equal "{}", @response.body
  end

  test ":create should return :bad_request if token is not sent" do
    json = {}.to_json
    post :create, body: json, as: :json

    assert_response :bad_request
  end

  test ":create should return :bad_request if token is not for a valid application" do
    app_mock = mock("app")
    app_mock.stubs(:valid?).returns(false)
    app_mock.stubs(:validation_reason).returns("mock error")
    BatchConnect::App.stubs(:from_token).returns(app_mock)
    json = { token: "sys/invalid" }.to_json
    post :create, body: json, as: :json

    assert_response :bad_request
  end

  test ":create should return :internal_server_error if BatchConnect throws error" do
    BatchConnect::App.stubs(:from_token).raises(Exception, 'error')
    json = { token: "sys/token" }.to_json
    post :create, body: json, as: :json

    assert_response :internal_server_error
  end

  test ":create should return session id when session is created successfully" do
    app_mock = mock("app")
    app_mock.stubs(:valid?).returns(true)
    BatchConnect::App.stubs(:from_token).returns(app_mock)
    session_mock = mock("session")
    session_mock.stubs(:id).returns("12345")
    @controller.stubs(:create_session).returns([true, session_mock])

    json = { token: "sys/token" }.to_json
    post :create, body: json, as: :json

    assert_response :ok
    response_hash = JSON.parse(@response.body).symbolize_keys
    assert_equal "12345", response_hash[:id]
  end

  test ":create should return :internal_server_error when session is not created" do
    app_mock = mock("app")
    app_mock.stubs(:valid?).returns(true)
    BatchConnect::App.stubs(:from_token).returns(app_mock)

    errors_mock = mock("errors")
    errors_mock.stubs(:full_messages).returns("error message")

    session_mock = mock("session")
    session_mock.stubs(:errors).returns(errors_mock)
    @controller.stubs(:create_session).returns([false, session_mock])

    json = { token: "sys/token" }.to_json
    post :create, body: json, as: :json

    assert_response :internal_server_error
    response_hash = JSON.parse(@response.body).symbolize_keys
    assert_equal "Unable to create session", response_hash[:message]
  end

  test ":create should return :internal_server_error when exception is thrown" do
    app_mock = mock("app")
    app_mock.stubs(:valid?).returns(true)
    BatchConnect::App.stubs(:from_token).returns(app_mock)

    @controller.stubs(:create_session).raises(Exception, "error")

    json = { token: "sys/token" }.to_json
    post :create, body: json, as: :json

    assert_response :internal_server_error
    response_hash = JSON.parse(@response.body).symbolize_keys
    assert_equal "Exception while creating session", response_hash[:message]
  end

  test ":destroy should return :not_found when session_id does not exists" do
    BatchConnect::Session.stubs(:exist?).returns(false)
    delete :destroy, params: { id: '12345' }
    assert_response :not_found
  end

  test ":destroy should return :no_content when session successfully deleted" do
    BatchConnect::Session.stubs(:exist?).returns(true)
    session_mock = mock("session")
    session_mock.stubs(:destroy).returns(true)
    BatchConnect::Session.stubs(:find).returns(session_mock)

    delete :destroy, params: { id: '12345' }
    assert_response :no_content
  end

  test ":destroy should return :internal_server_error when session cannon be deleted" do
    BatchConnect::Session.stubs(:exist?).returns(true)
    errors_mock = mock("errors")
    errors_mock.stubs(:full_messages).returns("error message")

    session_mock = mock("session")
    session_mock.stubs(:destroy).returns(false)
    session_mock.stubs(:errors).returns(errors_mock)

    BatchConnect::Session.stubs(:find).returns(session_mock)

    delete :destroy, params: { id: '12345' }
    assert_response :internal_server_error
    response_hash = JSON.parse(@response.body).symbolize_keys
    assert_equal "Unable to delete session", response_hash[:message]
  end

  test ":destroy should return :internal_server_error when exception is thrown" do
    BatchConnect::Session.stubs(:exist?).returns(true)

    session_mock = mock("session")
    session_mock.stubs(:destroy).raises(Exception, 'error')

    BatchConnect::Session.stubs(:find).returns(session_mock)

    delete :destroy, params: { id: '12345' }
    assert_response :internal_server_error
    response_hash = JSON.parse(@response.body).symbolize_keys
    assert_equal "Exception while deleting session", response_hash[:message]
  end

end