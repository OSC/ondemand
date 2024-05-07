json.id @project.id
json.name @project.name
json.description @project.description
json.icon @project.icon
json.directory @project.directory
if Configuration.project_size_enabled
  project_size = @project.size
  json.size project_size
  json.human_size number_to_human_size(project_size)
end
