# helper for product pages.
module ProductsHelper

  def products_title(type)
    if type == :dev
      t('dashboard.nav_develop_my_sandbox_apps_dev')
    elsif type == :usr
      t('dashboard.nav_develop_my_sandbox_apps_prod')
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
      html += %Q(<span class="text-success">#{fa_icon('check')}</span>)
    else
      html += %Q(<span class="text-danger">#{fa_icon('times')}</span>)
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
      class: "btn btn-#{color}",
      title: help,
      id: "#{key.to_s.downcase}_btn",
      data: {
        toggle: "cli",
        target: cli_product_path(key, name: @product.name, type: @type),
        title: title,
        cmd: "<code>#{display}</code>"
    })
  end

end
