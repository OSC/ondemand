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

  def git_prompt(path)
    Dir.chdir(path) do
      # get reference
      out = `HOME="" git symbolic-ref -q HEAD 2> /dev/null`.strip
      unless out.empty?
        /^(refs\/heads\/)?(?<ref>.+)$/ =~ out
      else
        out = `HOME="" git describe --tags --exact-match 2> /dev/null`.strip
        unless out.empty?
          ref = "tag:#{out}"
        else
          out = `HOME="" git describe --contains --all HEAD 2> /dev/null`.strip
          /^(remotes\/)?(?<ref>.+)$/ =~ out
          ref = `HOME="" git rev-parse --short HEAD 2> /dev/null`.strip unless ref
          ref = "detached:#{ref}"
        end
      end

      # get file info
      files = `HOME="" git status --porcelain`.split("\n")
      unstaged  = files.select {|v| /^\s\w .+$/ =~ v}.size
      staged    = files.select {|v| /^\w\s .+$/ =~ v}.size
      untracked = files.select {|v| /^\?\? .+$/ =~ v}.size
      total = unstaged + staged + untracked

      html = "<span data-toggle='popover' data-trigger='hover' data-placement='bottom' title='Git Status' data-content='<strong>Staged:</strong> #{staged}<br><strong>Unstaged:</strong> #{unstaged}<br><strong>Untracked:</strong> #{untracked}#{"<br>Please commit any changes or add necessary files to <code>.gitignore</code>" if total != 0}' data-html='true'>"
      html += "<small>[#{ref} S:#{staged} U:#{unstaged} ?:#{untracked}]</small> "
      if total == 0
        html += "<span class='text-success'>#{icon('check')}</span>"
      else
        html += "<span class='text-danger'>#{icon('times')}</span>"
      end
      html += "</span>"
      html.html_safe
    end
  end
end
