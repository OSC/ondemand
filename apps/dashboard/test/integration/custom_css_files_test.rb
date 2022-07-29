require 'test_helper'

class CustomCssFilesTest < ActionDispatch::IntegrationTest
 test "should add css tags when custom_css_files configuration is set" do
   stub_user_configuration({custom_css_files: ["test.css", "/custom/other.css"]})

   get '/'

   assert css_select("link") { |link| link['href'] == 'test.css' && !link['nonce'].nil? }
   assert css_select("link") { |link| link['href'] == '/custom/test.css' && !link['nonce'].nil? }
 end
end
