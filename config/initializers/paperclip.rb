# http://robots.thoughtbot.com/prevent-spoofing-with-paperclip
# allow stl files to be uploaded
Paperclip.options[:content_type_mappings] = {
  :stl => "text/plain"
}

# We use ":class/:id/:created_at/" to specify path uniqueness
Paperclip::Attachment.default_options[:path] = "#{AwesimRails.dataroot}/uploads/:class/:id/:created_at/:attachment/:filename"

# URL location points to file mount in routes called "/files"
# therefore this mirrors ':path' to some extent
Paperclip::Attachment.default_options[:url] = ":rails_relative_url_root/files/uploads/:class/:id/:created_at/:attachment/:filename"

# Necessary when rails app is hosted in subdirectory of domain
# e.g: http://www.example.com/rails1
Paperclip.interpolates :rails_relative_url_root do |attachment, style|
  Rails.application.config.action_controller.relative_url_root.to_s
end

# Necessary for path uniqueness when database is reset
Paperclip.interpolates :created_at do |attachment, style|
  attachment.instance.created_at.to_i
end
