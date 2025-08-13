# frozen_string_literal: true

# The controller for the system status page /dashboard/systemstatus
class SystemStatusController < ApplicationController
  def index
    @source = request.referer&.include?('system-status') ? 'app' : 'widget'
  end
end
