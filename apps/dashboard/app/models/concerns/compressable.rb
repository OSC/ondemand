module Compressable
  def compress
    system("tar -czvf #{directory}.tar.gz -C #{directory} .")
  end
end