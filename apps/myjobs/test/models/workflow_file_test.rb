require 'test_helper'

class WorkflowFileTest < ActiveSupport::TestCase
  test "it recognizes hidden files" do
    assert WorkflowFile.new(
        Pathname.new('/home/johrstrom/.wine/drive_c'),
        Pathname.new('/home/johrstrom/ondemand/and/so/on')
    ).under_dotfile?
  end
end
