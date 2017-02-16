module ProductsHelper
  def products_title(type)
    if type == :dev
      "My Sandbox Apps (Development)"
    elsif type == :usr
      "My Shared Apps (Production)"
    else
      "Undefined Title"
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
  # @param [String] title: The button label
  # @param [String] key: The key of the command in the CMDS hash ( See: controllers/products_controller.rb )
  # @param [String] display: The equivalent command to be displayed to the user
  # @param [optional, String] help: Tooltip text to be provided on hover. ( Default: none )
  # @param [optional, String] color: The bootstrap color of the button. Ex. "primary", "info", "success", etc. ( Default: "default" )
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
