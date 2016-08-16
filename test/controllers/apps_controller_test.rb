require 'test_helper'

class AppsControllerTest < ActionController::TestCase
  test "show sys app" do
    #FIXME:
    # When I do
    #
    #    app_url
    #
    # I rightfully get error: ActionController::UrlGenerationError: No route
    # matches {:type=>:sys, :controller=>"apps", :action=>"show"} missing
    # required keys: [:name]
    #
    # When I do
    #
    #    app_url(:myjobs)
    #
    # I get this error: ActionController::UrlGenerationError: No route matches
    # {:controller=>"apps", :action=>"/apps/show/myjobs"}
    #
    # This prevents me from adding tests for these route helpers.

    # get app_path(:activejobs)
    # assert_redirected_to "/pun/sys/activejobs"
  end
end
