module Deflateable
  def deflate
    system("tar -czvf #{directory}.tar.gz -C #{directory} .")
  end
end