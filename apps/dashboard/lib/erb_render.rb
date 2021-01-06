class ERBRender
  # Render a list of files using ERB
  def self.render_erb_files(files, binding: nil, remove_extension: true)
    files.each do |file|
      rendered_file = remove_extension ? file.sub_ext("") : file
      template      = file.read
      rendered      = erb_new(template).result(binding)

      file.rename rendered_file # keep same file permissions
      rendered_file.write(rendered)
    end  
  end

  def self.motd_render_erb(motd_file)
    ERB.new(motd_file.content).result
  end

  # pure function to render erb, properly setting the filename attribute
  # before rendering
  def self.render_erb_file(path:, contents:, binding:)
    erb = erb_new(contents) 
    erb.filename = path.to_s
    erb.result(binding)
  end
   
  def self.erb_new(contents)
    ERB.new(contents, nil, "-")
  end
end
