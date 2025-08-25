# Set the LANG environment variable
Rails.application.config.after_initialize do
  ENV['LANG']=I18n.t('locale_text_encoding')
end
