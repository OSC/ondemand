require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test 'update fails when manifest cannot be saved' do
    Dir.mktmpdir do |dir|
      base = Pathname.new(dir)
      app_dir = base.join('myapp')
      app_dir.mkpath
      manifest = app_dir.join('manifest.yml')
      manifest.write("---\nname: Old\n")

      DevRouter.stubs(:base_path).returns(base)
      File.chmod(0o444, manifest)

      product = DevProduct.new(name: 'myapp', found: true, title: 'New', description: 'desc', icon: 'fas://cog')

      refute product.update(title: 'Newer', description: 'desc')
      assert product.errors[:base].present?
      assert_equal 'Old', Manifest.load(manifest).name
    ensure
      File.chmod(0o644, manifest) if defined?(manifest) && manifest.exist?
    end
  end
end
