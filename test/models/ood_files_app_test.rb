require 'test_helper'

class OodFilesAppTest < ActiveSupport::TestCase

  setup do
    @app = OodFilesApp.new
  end

  def p(str)
    Pathname.new(str)
  end
end
