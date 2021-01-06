module ERBRenderUtils
  def erb(content, safe_level: nil, trim_mode: "-", binding: nil, filename_path: nil)
    erb = ERB.new(content, safe_level, trim_mode)
    erb.filename = filename_path.to_s if filename_path
    
    erb.result binding
  end
end
