# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  def setup
    @user_configuration = nil
  end

  test 'help_links should include server restart' do
    @user_configuration = stub({ profile_links: [], help_menu: [] })

    result = help_links

    assert_equal 1, result.apps.size
    assert_equal I18n.t('dashboard.nav_restart_server'), result.apps[0].title
  end

  test 'help_links should combine server restart with profile_links and help_menu' do
    @user_configuration = stub({ profile_links: [{ title: 'profile link', url: '/path' }],
                                 help_menu:     [{ title: 'help link', url: '/path' }] })

    result = help_links

    assert_equal 3, result.apps.size
    assert_equal I18n.t('dashboard.nav_restart_server'), result.apps[0].title
    assert_equal 'profile link', result.apps[1].title
    assert_equal 'help link', result.apps[2].title
  end

  test 'help_links should delegate to NavBar to create links' do
    config = { links: ['restart'] }
    @user_configuration = stub({ profile_links: [], help_menu: [] })

    NavBar.expects(:menu_items).with(config)
    help_links
  end

  test 'custom_css_paths should prepend public_url to all custom css file paths' do
    stub_files(:custom_css_files, ['/test.css'])
    assert_equal ['/public/test.css'], custom_css_paths

    stub_files(:custom_css_files, ['test.css'])
    assert_equal ['/public/test.css'], custom_css_paths

    stub_files(:custom_css_files, ['/custom/css/test.css'])
    assert_equal ['/public/custom/css/test.css'], custom_css_paths

    stub_files(:custom_css_files, ['custom/css/test.css'])
    assert_equal ['/public/custom/css/test.css'], custom_css_paths
  end

  test 'custom_css_paths should should handle nil and empty file paths' do
    stub_files(:custom_css_files, ['/test.css', nil, 'other.css'])
    assert_equal ['/public/test.css', '/public/other.css'], custom_css_paths

    stub_files(:custom_css_files, [nil])
    assert_equal [], custom_css_paths

    stub_files(:custom_css_files, ['/test.css', '', 'other.css'])
    assert_equal ['/public/test.css', '/public/other.css'], custom_css_paths

    stub_files(:custom_css_files, [''])
    assert_equal [], custom_css_paths
  end

  test 'custom_javascript_paths should prepend public_url to all js file paths' do
    stub_files(:custom_javascript_files, ['/test.js'])
    assert_equal expected_js_paths(['/public/test.js']), custom_javascript_paths

    stub_files(:custom_javascript_files, ['test.js'])
    assert_equal expected_js_paths(['/public/test.js']), custom_javascript_paths

    stub_files(:custom_javascript_files, ['/custom/js/test.js'])
    assert_equal expected_js_paths(['/public/custom/js/test.js']), custom_javascript_paths

    stub_files(:custom_javascript_files, ['custom/js/test.js'])
    assert_equal expected_js_paths(['/public/custom/js/test.js']), custom_javascript_paths
  end

  test 'custom_javascript_paths should handle nil and empty file paths' do
    stub_files(:custom_javascript_files, ['/test.js', nil, 'other.js'])
    assert_equal expected_js_paths(['/public/test.js', '/public/other.js']), custom_javascript_paths

    stub_files(:custom_javascript_files, [nil])
    assert_equal expected_js_paths([]), custom_javascript_paths

    stub_files(:custom_javascript_files, ['/test.js', '', 'other.js'])
    assert_equal expected_js_paths(['/public/test.js', '/public/other.js']), custom_javascript_paths

    stub_files(:custom_javascript_files, [''])
    assert_equal expected_js_paths([]), custom_javascript_paths
  end

  test 'custom_javascript_paths should handle hash config with src and type' do
    stub_files(:custom_javascript_files, [{ src: '/test.js', type: 'module' }])
    assert_equal expected_js_paths(['/public/test.js'], type: 'module'), custom_javascript_paths

    stub_files(:custom_javascript_files, [{ src: '/test.js' }])
    assert_equal expected_js_paths(['/public/test.js'], type: ''), custom_javascript_paths

    stub_files(:custom_javascript_files, [{ type: 'module' }])
    assert_equal [], custom_javascript_paths
  end

  def stub_files(type, file_config)
    public_url = Pathname.new('/public')
    @user_configuration = stub(type => file_config, :public_url => public_url)
  end

  def expected_js_paths(js_file_config, type: '')
    js_file_config.map do |item|
      { src: item, type: type }
    end
  end

  test 'icon_tag should should render icon tag for known icon schemas' do
    @user_configuration = stub({ public_url: Pathname.new('/public') })
    ['fa', 'fas', 'far', 'fab', 'fal'].each do |icon_schema|
      image_uri = URI("#{icon_schema}://icon_name")
      html = Nokogiri::HTML(icon_tag(image_uri))

      icon_html = html.at_css('i')
      assert_equal true, icon_html['class'].include?(icon_schema)
      assert_equal true, icon_html['class'].include?('icon_name')
    end
  end

  test 'icon_tag should should render image tag prefixing relative_url_root if image URI does not start with public_url' do
    @user_configuration = stub({ public_url: Pathname.new('/public') })
    config.stubs(:relative_url_root).returns('/prefix')
    image_uri = URI('/path/to/image.png')
    html = Nokogiri::HTML(icon_tag(image_uri))

    image_html = html.at_css('img')
    assert_equal 'app-icon', image_html['class']
    assert_equal image_uri.to_s, image_html['title']
    assert_equal '/prefix/path/to/image.png', image_html['src']
  end

  test 'icon_tag should should render image tag without prefixing relative_url_root if image URI starts with public_url' do
    @user_configuration = stub({ public_url: Pathname.new('/public') })
    config.stubs(:relative_url_root).returns('/prefix')
    image_uri = URI('/public/path/image.png')
    html = Nokogiri::HTML(icon_tag(image_uri))

    image_html = html.at_css('img')
    assert_equal 'app-icon', image_html['class']
    assert_equal image_uri.to_s, image_html['title']
    assert_equal image_uri.to_s, image_html['src']
  end

  test 'favicon tag should use public asset uri in production mode' do
    Rails.stubs(:env).returns(stub('production?', production?: true))

    @user_configuration = stub({ public_url: Pathname.new('/public') })
    html = Nokogiri::HTML(favicon())
    
    favicon_html = html.at_css("link")
    assert_equal '/public/favicon.ico', favicon_html['href']
  end

  test 'favicon tag should use local asset uri in test mode' do
    Rails.stubs(:env).returns(stub('production?', production?: false))

    @user_configuration = stub({ public_url: Pathname.new('/public') })
    html = Nokogiri::HTML(favicon())
    
    favicon_html = html.at_css("link")
    assert_equal '/images/favicon.ico', favicon_html['href']
  end

  test 'favicon tag should have a reffererpolicy attribute with value origin' do
    Rails.stubs(:env).returns(stub('production?', production?: true))

    @user_configuration = stub({ public_url: Pathname.new('/public') })
    html = Nokogiri::HTML(favicon())

    favicon_html = html.at_css("link")
    assert_equal 'origin', favicon_html['referrerpolicy']
  end 
end
