# frozen_string_literal: true

# helper class for files paths because of the rails issue below
# where negative lookaheads don't work in rails 7.
# https://github.com/rails/rails/issues/47244
class FilePathConstraint
  def matches?(request)
    request.params[:fs].to_s.match?(/(?!(edit|api\/v1))[^\/]+/)
  end
end
