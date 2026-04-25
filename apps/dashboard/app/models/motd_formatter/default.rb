module MotdFormatter
  # Built-in default MOTD shown when MOTD_PATH is unset.
  class Default < Markdown
    def initialize(_motd_file = nil)
      @title = I18n.t('dashboard.motd_title')
      markdown = I18n.t('dashboard.motd_default_md', default: I18n.t('dashboard.motd_default_md', locale: :en))
      content = OodAppkit.markdown.render(markdown)
      @content = safe_content(content)
    end

    def to_partial_path
      'dashboard/motd_markdown'
    end
  end
end
