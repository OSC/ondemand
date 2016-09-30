module ProductsHelper
  def products_title(type)
    if type == :dev
      "Sandbox Apps (Development)"
    elsif type == :usr
      "Shared Apps (Production)"
    else
      "Undefined Title"
    end
  end
end
