require 'test_helper'

class MotdTest < ActiveSupport::TestCase
  # test date order of example Motd file
  #
  test "motd message date format" do

    date = Date.new(2016, 5, 4)

    # assume year month day
    msg = "2016/05/04\n--- NEW CLUSTER\n\nSomething good!"
    assert_equal date, MotdFile::Message.from(msg).date
    msg = "2016-05-04\n--- NEW CLUSTER\n\nSomething good!"
    assert_equal date, MotdFile::Message.from(msg).date
    msg = "2016.05.04\n--- NEW CLUSTER\n\nSomething good!"
    assert_equal date, MotdFile::Message.from(msg).date
    msg = "2016 05 04\n--- NEW CLUSTER\n\nSomething good!"
    assert_equal nil, MotdFile::Message.from(msg)
    msg = "2016+05+04\n--- NEW CLUSTER\n\nSomething good!"
    assert_equal nil, MotdFile::Message.from(msg)
  end

end
