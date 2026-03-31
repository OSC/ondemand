require 'test_helper'

class AnnouncementParseErrorTest < ActionDispatch::IntegrationTest
  test 'parsing error shows danger announcement' do
    f = Tempfile.open(%w[announcement .yml])
    # write malformed YAML
    f.write("::: this is not yaml: [\n")
    f.close

    stub_user_configuration({ announcement_path: [f.path] })

    begin
      get '/'
      assert_response :success

      assert_select 'div.alert-danger.card' do
        assert_select 'div.card-header', /Could not render announcement/
        assert_select 'div.card-body', /mapping values/
      end
    ensure
      stub_user_configuration({})
    end
  end
end