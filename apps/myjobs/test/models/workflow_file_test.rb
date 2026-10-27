require 'test_helper'

class WorkflowFileTest < ActiveSupport::TestCase
  test "is dotfile does not detect hidden folders" do
    refute WorkflowFile.new(
        Pathname.new('/home/johrstrom/.wine/drive_c'),
        Pathname.new('/home/johrstrom/ondemand/and/so/on')
    ).is_dotfile?
  end

  test "is dotfile detects hidden files" do 
    assert WorkflowFile.new(
      Pathname.new('/home/johrstrom/wine/.drive_c'),
      Pathname.new('/home/johrstrom/ondemand/and/so/on')
    ).is_dotfile?
  end
end
