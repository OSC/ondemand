# frozen_string_literal: true

module MotdFormatter
  # Utility class for rendering Markdown MOTD files after ERB rendering them.
  class MarkdownErb < BaseFormatter
    attr_reader :content, :title

    def initialize(motd_file)
      motd_file ||= MotdFile.new unless motd_file
      @title = motd_file.title
      content = OodAppkit.markdown.render(ERB.new(motd_file.content).result)
      @content = safe_content(content)
    end

    def to_partial_path
      'dashboard/motd_markdown'
    end
  end
end
