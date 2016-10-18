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
end
