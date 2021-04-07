module FilesHelper
  #FIXME: handle by Transfer#all model method
  def sort_by_created_at(transfers)
    transfers.sort_by { |t| - t.created_at }
  end

  def shell_links
    html = ""

    Configuration.login_clusters.each{ |cluster|
      html.concat(tag.a(
        cluster.title,
        href: OodAppkit.shell.url(path: cluster.title.lower).to_s,
        class: 'dropdown-item',
        role: 'menuitem',
        target: '_blank'
      ))
    }

    html.html_safe
  end

  def path_segment_with_slash(segment, counter, total)
    # TODO: ucomment if we decide to omit trailing slash on current directory
    # if counter == 0 || counter == total - 1
    if counter == 0
      segment
    else
      segment + " /"
    end
  end
end
