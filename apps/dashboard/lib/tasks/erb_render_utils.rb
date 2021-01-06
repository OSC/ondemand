module ERBRenderUtils
  def erb(content, safe_level:, trim_mode: "-", binding:)
    ERB.new(content, safe_level, trim_mode).result binding
  end
end
