def ctr_base_url
  "http://localhost:8080"
end

def browser_login(browser)
  browser.goto ctr_base_url
  browser.text_field(id: 'username').set "ood@localhost"
  browser.text_field(id: 'password').set "password"
  browser.button(id: 'submit-login').click
end