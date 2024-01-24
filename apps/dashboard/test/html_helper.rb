# helper functions for tests that verify html elements like
# integration tests.
class ActiveSupport::TestCase

  def nav_link(title)
    css_select("nav a.nav-link[title='#{title}']")
  end

  def dropdown_list(title)
    css_select("nav a.nav-link.dropdown-toggle[title='#{title}'] + ul")
  end

  def dropdown_links
    'nav a.nav-link.dropdown-toggle[title]'
  end

  def dropdown_link(order)
    "nav #navbar li.dropdown:nth-of-type(#{order}) a[title]"
  end

  # given a dropdown list, return the list items as an array of strings
  # with symbols for header or divider
  def dropdown_list_items(list)
    css_select(list, "li").map do |item|
      if item['class'] && item['class'].include?("divider")
        :divider
      elsif item['class'] && item['class'].include?("dropdown-header")
        { :header => item.text.strip }
      else
        item.text.strip
      end
    end
  end

  # given a dropdown list, return the list items as an array of URL strings
  def dropdown_list_items_urls(list)
    css_select(list, "a").map do |item|
      item.attributes['href'].try(:value) || ""
    end
  end

  def pinned_app_link_css_query(col_size, ref)
    "div.row > div.col-md-#{col_size} > div.row > div.col-sm-3.col-md-3.app-launcher-container > div > a[href='#{ref}']"
  end

  def pinned_app_row_css_query(col_size)
    "div.row > div.col-md-#{col_size} > div.row > div.col-sm-3.col-md-3.app-launcher-container"
  end

end