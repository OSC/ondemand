#frozen_string_literal: true

# Helpers for the projects page /projects
module ProjectsHelper
    def project_markdown(text)
        ProjectReadmeMarkdownRenderer.renderer.render(text).html_safe
    end
end