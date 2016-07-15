class DashboardController < ApplicationController
  def index
    flash.now[:alert] = "OnDemand requires a newer version of the browser you are using. Current browser requirements include IE10+, Firefox 19+, Chrome 34+, Safar 8+." unless view_context.browser.modern?
    flash.now[:alert] = "OnDemand is not yet optimized for mobile use." if view_context.browser.device.mobile?

    @motd_file = MotdFile.new
  end
end
