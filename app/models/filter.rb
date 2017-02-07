class Filter
  attr_accessor :title, :cookie_id, :filter_block

  class << self
    attr_accessor :list
  end

  self.list = []
  self.list << Filter.new.tap { |f|
    user = OodSupport::User.new.name
    f.title = "Your Jobs"
    f.cookie_id = "user"
    f.filter_block = Proc.new { |id, attr| attr[:Job_Owner] =~ /^#{user}@/ }
  }
  self.list << Filter.new.tap { |f|
    group = OodSupport::User.new.group.name
    f.title = "Your Group's Jobs (#{OodSupport::User.new.group.name})"
    f.cookie_id = "group"
    f.filter_block = Proc.new { |id, attr| attr[:attribs] && attr[:attribs][:Account_Name] == group }
  }
  self.list << Filter.new.tap { |f|
    f.title = "All Jobs"
    f.cookie_id = "all"
    f.filter_block = Proc.new { |a| a }
  }

end
