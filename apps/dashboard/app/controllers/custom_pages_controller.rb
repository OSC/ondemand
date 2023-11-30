# frozen_string_literal: true

# The controller to add new pages with layouts and widgets based on configuration.
#
# It uses a page_code coming from the URL to determine which layout to use.
# If the page_code does not match a configuration object, an error message is displayed.
class CustomPagesController < ApplicationController
  include MotdConcern
  
  def index
    page_code = params[:page_code]
    set_motd
    @page_layout = @user_configuration.custom_pages.fetch(page_code.to_sym, {})
    flash.now[:alert] = t('dashboard.custom_pages.invalid', page: page_code) if @page_layout.empty?
  end
end
