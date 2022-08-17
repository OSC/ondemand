class NavApp < OodApp

  attr_reader :token

  # Creates a NavApp from an OodApp or BatchConnect::App
  def self.from_app(app, token: nil)
    NavApp.new(app.router, token: token)
  end

  def initialize(router, token: nil)
    super(router)

    @token = token || router.token
  end

  def sub_app_list
    [BatchConnect::App.from_token(token)]
  end
end
