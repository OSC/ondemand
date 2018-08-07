module ProductsHelper

  class RenderReadmeMarkdown < Redcarpet::Render::HTML
    attr_reader :app_path

    def self.extensions
      {
        autolink: true,
        tables: true,
        strikethrough: true,
        fenced_code_blocks: true,
        no_intra_emphasis: true
      }
    end
    
    def self.render_opts
      {escape_html: true}
    end
    
    def self.renderer(app_path: nil)
      Redcarpet::Markdown.new(self.new(self.render_opts.merge(app_path: app_path)), self.extensions)
    end
    
    # override to customize the default renderer options
    def initialize(opts={})
      super(opts)
      @app_path = opts.fetch(:app_path, nil)
    end

    # open link in new window
    def link(link, title, content)
      link = OodAppkit.files.api(path: @app_path.to_s + '/' + link).to_s if @app_path && relative?(link)
      return "<a href=\"#{link}\" target=\"_blank\">#{content}</a>" unless id_link?(link)
      return "<a href=\"#{link}\">#{content}</a>"
    end

    def autolink(link_text, link_type)
      if link_type == :email
        "<a href=\"mailto:#{link_text}\" target=\"_top\">#{link_text}</a>"
      else
        link(link_text, link_text, link_text)
      end
    end
    
    def image(link, title, alt_text)
      link = OodAppkit.files.api(path: @app_path.to_s + '/' + link).to_s if @app_path && relative?(link)
      "<img src=\"#{link}\" title=\"#{title}\" alt=\"#{alt_text}\" style=\"max-width:100%;\"/>"
    end
    
    def header(text, header_level)
      "<h#{header_level} id=\"#{title_to_id(text)}\">#{text}</h#{header_level}>"
    end
    
    private
    
    def relative?(path)
      !URI(path).scheme && !URI(path).host && !path.start_with?("/") && !path.start_with?("#")
    end
    
    def id_link?(path)
      !URI(path).scheme && !URI(path).host && URI(path).path == "" && URI(path).fragment != "" && path.start_with?("#")
    end
    
    def title_to_id(text)
      text.downcase.gsub(/[^a-z]+/, '-')
    end
    
  end

  def products_title(type)
    if type == :dev
      "My Sandbox Apps (Development)"
    elsif type == :usr
      "My Shared Apps (Production)"
    else
      "Undefined Title"
    end
  end

  def app_type_title(app)
    if app.passenger_app?
      if app.passenger_rack_app?
        if app.passenger_rails_app?
          if app.passenger_railsdb_app?
            "Passenger Rails App with SQLite database"
          else
            "Passenger Rails App"
          end
        else
          "Passenger Rack App"
        end
      elsif app.passenger_nodejs_app?
        "Passenger Node App"
      elsif app.passenger_python_app?
        "Passenger WSGI App"
      elsif app.passenger_meteor_app?
        "Passenger Meteor App"
      else
        "Passenger App"
      end
    elsif app.batch_connect_app?
      "Batch Connect App"
    else
      "Unknown"
    end
  end

  def git_prompt(product)
    files     = product.uncommitted_files
    unstaged  = files[:unstaged].size
    staged    = files[:staged].size
    untracked = files[:untracked].size
    total     = unstaged + staged + untracked

    version   = product.version

    html = %Q(<span data-toggle="popover" data-trigger="hover" data-placement="bottom" title="Git Status" data-content="<strong>Staged:</strong> #{staged}<br><strong>Unstaged:</strong> #{unstaged}<br><strong>Untracked:</strong> #{untracked}#{"<br>Please commit any changes or add necessary files to <code>.gitignore</code>" if total != 0}" data-html="true">)
    html += %Q(<small>[#{version} S:#{staged} U:#{unstaged} ?:#{untracked}]</small> )
    if total == 0
      html += %Q(<span class="text-success">#{icon('check')}</span>)
    else
      html += %Q(<span class="text-danger">#{icon('times')}</span>)
    end
    html += %Q(</span>)
    html.html_safe
  end

  def ssh_key
    target = Pathname.new("~/.ssh/id_rsa.pub").expand_path
    File.read(target) if target.file?
  end

  # A custom button helper for command line tools
  #
  # @param title [String] The button label
  # @param key [String] The key of the command in the CMDS hash ( See: controllers/products_controller.rb )
  # @param display [String] The equivalent command to be displayed to the user
  # @param help [optional, String] Tooltip text to be provided on hover. ( Default: none )
  # @param color [optional, String] The bootstrap color of the button. Ex. "primary", "info", "success", etc. ( Default: "default" )
  def command_btn(title:, key:, display:, help: nil, color: "default")
    button_tag(title,
      class: "btn btn-#{color} btn-block",
      title: help,
      data: {
        toggle: "cli",
        target: cli_product_path(key, name: @product.name, type: @type),
        title: title,
        cmd: "<code>#{display}</code>"
    })
  end

end
