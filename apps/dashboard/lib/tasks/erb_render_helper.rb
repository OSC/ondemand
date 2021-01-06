module ERBRenderHelper
  # To add in common use cases in ERB rendering when needed
  def groups
      @groups ||= OodSupport::Process.groups.map(&:name)
  end
end
