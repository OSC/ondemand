# This class matches pinned apps configuration tokens to a given OodApp
# Tokens can be globs like 'sys/*', specific apps like 'sys/jupyter'
# or 'sys/bc_desktop/pitzer' for subapps
class TokenMatcher

  attr_reader :matchers, :token

  # @param [String] token the token to match apps against
  def initialize(token)
    @matchers = []
    @token = token

    if token.is_a?(String)
      matchers.append('glob_match?')
    end
  end

  def matches_app?(app)
    if matchers.empty?
      false
    else
      matchers.all? { |matcher| method(matcher).call(app) }
    end
  end

  private

  def glob_match?(app)
    glob_match = File.fnmatch(token, app.token, File::FNM_EXTGLOB)
    sub_app_match = token.start_with?(app.token) # find sys/bc_desktop/pitzer from sys/bc_desktop

    glob_match || sub_app_match
  end
end