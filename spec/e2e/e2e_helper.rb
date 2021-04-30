
require 'rake'
require_relative '../../lib/tasks/build_utils'
load File.expand_path("../../../Rakefile", __FILE__)

def new_browser
  Watir::Browser.new :chrome, headless: true, options: { args: ['--disable-dev-shm-usage'] }
end

def ctr_base_url
  "http://localhost:8080"
end

def browser_login(browser)
  # sometimes you need to retry to let the container start up, so retry to make the tests
  # a little less flaky
  [*1..5].each do |try|
    begin
      browser.goto ctr_base_url
      browser.text_field(id: 'username').set "ood@localhost"
      browser.text_field(id: 'password').set "password"
      browser.button(id: 'submit-login').click
      break
    rescue => e
      puts "can't login. retry number #{try}"
      raise e if try == 5

      `sleep 3`
    end
  end
end

def hook_fixture(file)
  "#{File.expand_path('.')}/spec/fixtures/hooks/#{file}"
end

def portal_fixture(file)
  "#{File.expand_path('.')}/spec/fixtures/config/ood_portal/#{file}"
end

def container_exec(cmd)
  `#{container_runtime} exec #{test_image_name} #{cmd}`.to_s
end
