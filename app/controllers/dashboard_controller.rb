class DashboardController < ApplicationController
  def index
    @user = User.new
  end
end
