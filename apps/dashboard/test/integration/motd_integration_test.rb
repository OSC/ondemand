# frozen_string_literal: true

require 'test_helper'

# Test various message of the day formats in html
class MotdIntegrationTest < ActionDispatch::IntegrationTest
  test 'default RSS MOTD sanitizes HTML' do
    env = {
      MOTD_FORMAT: 'rss',
      MOTD_PATH:   Rails.root.join('test/fixtures/files/motd_rss').to_s
    }

    with_modified_env(env) do
      get('/')
    end

    items = css_select('[data-motd-rss-item]')
    assert_equal(10, items.size)

    # no scripts or forms
    forms = css_select('[data-motd-rss-item] form')
    assert_equal(0, forms.size)

    scripts = css_select('[data-motd-rss-item] script')
    assert_equal(0, scripts.size)
  end

  test 'RSS MOTD can render HTML when configured' do
    env = {
      MOTD_FORMAT:          'rss',
      MOTD_PATH:            Rails.root.join('test/fixtures/files/motd_rss').to_s,
      OOD_MOTD_RENDER_HTML: 'yesplz'
    }

    with_modified_env(env) do
      get('/')
    end

    items = css_select('[data-motd-rss-item]')
    assert_equal(10, items.size)

    # now with HTML rendering we have forms & scripts
    forms = css_select('[data-motd-rss-item] form')
    assert_equal(2, forms.size)

    scripts = css_select('[data-motd-rss-item] script')
    assert_equal(2, scripts.size)
  end

  test 'default Markdown MOTD sanitizes HTML' do
    env = {
      MOTD_FORMAT: 'markdown',
      MOTD_PATH:   Rails.root.join('test/fixtures/files/motd_md_w_html').to_s
    }

    with_modified_env(env) do
      get('/')
    end

    items = css_select('[data-motd-md]')
    assert_equal(1, items.size)

    # no scripts or forms
    forms = css_select('[data-motd-rss-item] form')
    assert_equal(0, forms.size)

    scripts = css_select('[data-motd-rss-item] script')
    assert_equal(0, scripts.size)
  end

  test 'Markdown MOTD can render HTML when configured' do
    env = {
      MOTD_FORMAT:          'markdown',
      MOTD_PATH:            Rails.root.join('test/fixtures/files/motd_md_w_html').to_s,
      OOD_MOTD_RENDER_HTML: 'yesplz'
    }

    with_modified_env(env) do
      get('/')
    end

    items = css_select('[data-motd-md]')
    assert_equal(1, items.size)

    # scripts & forms are preserved
    forms = css_select('[data-motd-md] form')
    assert_equal(1, forms.size)

    scripts = css_select('[data-motd-md] script')
    assert_equal(1, scripts.size)
  end
end
