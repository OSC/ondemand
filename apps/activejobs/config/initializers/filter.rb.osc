# Add a filter by group option and insert it after the first option.
Filter.list.insert(1, Filter.new.tap { |f|
  group = OodSupport::User.new.group.name
  f.title = "Your Group's Jobs (#{group})"
  f.filter_id = "group"
  # N.B. Need to use :egroup here for now. My Oodsupport group name is 'appl' but job 'Account_Name' is 'PZS0002'
  f.filter_block = Proc.new { |job| job.native[:egroup] == group }
})
