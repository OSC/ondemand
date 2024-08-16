# frozen_string_literal: true

# This class matches apps configuration tokens to a given OodApp.
# Tokens can either be strings that are globs like 'sys/*', specific apps like
# 'sys/jupyter' or 'sys/bc_desktop/pitzer' for subapps. They can also be hashes
# Hashes can be known attributes like category, subcategory, type to filter off
# of those. And/or they can be arbitrary key value pairs to filter off of OodApp#metadata.
class TokenMatcher
  attr_reader :matchers, :token

  # @param [String, Hash] token the token to match apps against
  def initialize(token)
    @matchers = []
    @token = token

    case token
    when String
      matchers.append('glob_match?')
    when Hash
      matchers.append('same_type?') unless token[:type].nil?
      matchers.append('same_category?') unless token[:category].nil?
      matchers.append('same_subcategory?') unless token[:subcategory].nil?
      matchers.append('metadata_match?') if token_has_metadata?
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
    # find sys/bc_desktop/pitzer from sys/bc_desktop
    # adding trailing slash to avoid token matching apps with same prefix
    # eg: sys/bc_jupyter matching sys/bc_jupyter_osc
    sub_app_match = app.token.start_with?(File.join(token, '')) unless token.empty?

    glob_match || sub_app_match
  end

  def token_has_metadata?
    token.to_h.reject do |k, _|
      [:type, :category, :subcategory].include?(k)
    end.any?
  end

  def same_category?(app)
    token[:category].to_s == app.category
  end

  def same_subcategory?(app)
    token[:subcategory].to_s == app.subcategory
  end

  def same_type?(app)
    token[:type].to_s.to_sym == app.type
  end

  def metadata_match?(app)
    app.metadata.select do |key, value|
      File.fnmatch(token[key.to_sym].to_s, value, File::FNM_EXTGLOB | File::FNM_CASEFOLD)
    end.any?
  end
end
