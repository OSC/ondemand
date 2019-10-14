class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :set_locale

  def set_locale
    I18n.locale = ::Configuration.locale
  rescue I18n::InvalidLocale => e
    logger.warn "I18n::InvalidLocale #{::Configuration.locale}: #{e.message}"
  end
end
