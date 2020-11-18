json.path @path.to_s
json.url files_path(@path).to_s
json.files @files do |f|
  json.id f[:id]
  json.type f[:directory] ? 'd' : 'f'
  json.name f[:name]

  # FIXME: do this join clientside?
  json.url files_path(@path.join(f[:name]).to_s)
  json.size f[:size]
  json.modified_at f[:date]
  json.owner f[:owner]
  json.mode f[:mode]
end
json.breadcrumbs_html render partial: 'breadcrumb.html.erb', collection: @path.descend, as: :file
