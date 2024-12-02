# frozen_string_literal: true

module MotdFormatter
  class BaseFormatter
    include ActionView::Helpers::SanitizeHelper

    def safe_content(content)
      if Configuration.motd_render_html?
        content.html_safe
      else
        sanitize(content)
      end
    end
  end
end
