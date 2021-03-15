# helper functions for tests that verify html elements like
# integration tests.
class ActiveSupport::TestCase

  def dropdown_list(title)
    css_select("li.dropdown[title='#{title}'] ul")
  end

  def dropdown_link(order)
    ".navbar-expand-md > #navbar li.dropdown:nth-of-type(#{order}) a"
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
end