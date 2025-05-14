# frozen_string_literal: true

# TODO: Refactor batch_connect_test.rb to include tests that require slurm
# (testing that things submit) and pull out/write tests for widgets (do not
# require form submission) into this file - perhaps a batch_connect_test/
# directory

require 'application_system_test_case'
require 'ood_core/job/adapters/slurm'

class BatchConnectWidgetsTest < ApplicationSystemTestCase
  def setup
    stub_sys_apps
    stub_user
    Configuration.stubs(:bc_dynamic_js).returns(true)
    Configuration.stubs(:bc_dynamic_js?).returns(true) #stub the alias too
  end

  def make_bc_app(dir, form)
    SysRouter.stubs(:base_path).returns(Pathname.new(dir))
    app_dir = "#{dir}/app".tap { |d| Dir.mkdir(d) }
    stub_scontrol
    stub_sacctmgr
    stub_git(app_dir)
    Pathname.new(app_dir).join('form.yml').write(form)
  end

  test 'path_selector can be hidden with data-hide-*' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
          - hide_path
        attributes:
          path:
            widget: 'path_selector'
            directory: "#{Rails.root}"
          hide_path:
            widget: 'select'
            options:
              - ['show path', 'show path']
              - ['hide path', 'hide path', data-hide-path: true]
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')

      select('show path', from: 'batch_connect_session_context_hide_path')
      assert find('#batch_connect_session_context_path')
      assert find("[data-bs-target='#batch_connect_session_context_path_path_selector']")

      select('hide path', from: 'batch_connect_session_context_hide_path')
      refute find('#batch_connect_session_context_path', visible: :hidden).visible?
      refute find("[data-bs-target='#batch_connect_session_context_path_path_selector']", visible: :hidden).visible?
    end
  end

  test 'path_selector can filter by file type matching an expression' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")
      
      ['test.py', 'test.rbpy'].each do |file|
        FileUtils.touch("#{Rails.root}/tmp/#{file}")
      end

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
            directory: "#{Rails.root}/tmp"
            show_files: true
            file_pattern: \\.py
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')

      click_on 'Select Path'
      sleep 0.5

      table_id = "batch_connect_session_context_path_path_selector_table"
      shown_dirs_and_files = find_all("##{table_id} tr td").map { |td| td["innerHTML"] }

      assert(shown_dirs_and_files.any? { |file| file.match("test.py") })
      refute(shown_dirs_and_files.any? { |file| file.match("test.rb") })
    end
  end

  test 'path_selector handles invalid regular expressions' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")
      
      Tempfile.new("test.py", "#{Rails.root}/tmp")
      Tempfile.new("test.rb", "#{Rails.root}/tmp")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
            directory: "#{Rails.root}/tmp"
            show_files: true
            file_pattern: \.doesn't(compile
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')

      find('.alert-danger')
    end
  end

  test 'path_selector handles no provided file pattern' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")
      
      Tempfile.new("test.py", "#{Rails.root}/tmp")
      Tempfile.new("test.rb", "#{Rails.root}/tmp")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
            directory: "#{Rails.root}/tmp"
            show_files: true
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')

      click_on 'Select Path'

      sleep 1

      table_id = "batch_connect_session_context_path_path_selector_table"
      shown_dirs_and_files = find_all("##{table_id} tr td").map { |td| td["innerHTML"] }

      assert shown_dirs_and_files.any? { |file| file.match("test.py") }
      assert shown_dirs_and_files.any? { |file| file.match("test.rb") } 
    end
  end

  test 'path_selector will not have URL encoded data' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")
      base_id = 'batch_connect_session_context_path'
      filename = "#{Rails.root}/tmp/file with spaces"
      FileUtils.touch(filename)

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
            directory: "#{Rails.root}/tmp"
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)

      visit new_batch_connect_session_context_url('sys/app')

      click_on 'Select Path'
      sleep 0.5

      find('span', text: 'file with spaces').click
      find("##{base_id}_path_selector_button").click

      assert_equal(filename, find("##{base_id}").value)
    end
  end

  test 'path_selector retains URL encodes if they are present' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")
      base_id = 'batch_connect_session_context_path'
      filename = "#{Rails.root}/tmp/#{CGI.escape('foo/ bar.txt')}"
      FileUtils.touch(filename)

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - path
        attributes:
          path:
            widget: 'path_selector'
            directory: "#{Rails.root}/tmp"
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)

      visit new_batch_connect_session_context_url('sys/app')

      click_on 'Select Path'
      sleep 0.5

      # note the text here is URL encoded
      find('span', text: 'foo%2F+bar.txt').click
      find("##{base_id}_path_selector_button").click

      # note that the variable 'filename' is URL encoded
      assert_equal(filename, find("##{base_id}").value)
    end
  end

  test 'data-label-* allows select options to dynamically change the label of another form element' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - node_type
          - cores
        attributes:
          node_type:
            widget: select
            options:
              - ['small', 'small', data-label-cores: 'Number of Cores (1-4)']
              - ['medium', 'medium', data-label-cores: 'Number of Cores (1-8)']
              - ['large', 'large', data-label-cores: 'Number of Cores (1-16)']
          cores:
            widget: "number_field"
            required: true
            value: 1
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')

      label = find("label[for='batch_connect_session_context_cores']")
      assert_equal label.text, "Number of Cores (1-4)"

      select('medium', from: 'batch_connect_session_context_node_type')

      label = find("label[for='batch_connect_session_context_cores']")
      assert_equal label.text, "Number of Cores (1-8)"
    end
  end

  test 'global_bc_form_items work correctly' do
    Dir.mktmpdir do |dir|
      app_dir = "#{dir}/app".tap { |d| FileUtils.mkdir(d) }
      Configuration.stubs(:config).returns({ 
        global_bc_form_items: {
          global_queues: {
            widget: 'select',
            label: 'Special Queues',
            options: [
              ['A', 'a'],
              ['B', 'b'],
              ['C', 'c']
            ]
          }
        }
      })

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - global_queues
      HEREDOC

      make_bc_app(app_dir, form)
      visit new_batch_connect_session_context_url('sys/app')

      widget = find("##{bc_ele_id('global_queues')}")
      options = find_all_options('global_queues', nil)
      label = find("[for='#{bc_ele_id('global_queues')}']")

      assert_equal('select', widget.tag_name)
      assert_equal(['a', 'b', 'c'], options.map(&:value))
      assert_equal(['A', 'B', 'C'], options.map(&:text))

      assert_equal('Special Queues', label.text)
    end
  end

  test 'global_bc_form_items default correctly' do
    Dir.mktmpdir do |dir|
      app_dir = "#{dir}/app".tap { |d| FileUtils.mkdir(d) }

      # no configuration for 'global_queues'
      Configuration.stubs(:config).returns({})

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - global_queues
      HEREDOC

      make_bc_app(app_dir, form)
      visit new_batch_connect_session_context_url('sys/app')

      widget = find("##{bc_ele_id('global_queues')}")
      label = find("[for='#{bc_ele_id('global_queues')}']")

      # not a select widget, it's a text input with the default label
      assert_equal('input', widget.tag_name)
      assert_equal('text', widget[:type])
      assert_equal('Global Queues', label.text)
    end
  end

  test 'forms correctly deal with capitalized ids' do
    Dir.mktmpdir do |dir|
      form = <<~HEREDOC
        ---
        form:
          - switcher
          - Eastern_City
          - Western_City
        attributes:
          switcher:
            widget: 'select'
            options:
              - ["east", data-hide-Western-City: true]
              - ["west", data-hide-Eastern-City: true]
      HEREDOC

      make_bc_app(dir, form)

      visit(new_batch_connect_session_context_url('sys/app'))

      # select east, and west is no longer visible. Also note that the id is lowercase.
      select('east', from: bc_ele_id('switcher'))
      assert(find("##{bc_ele_id('eastern_city')}").visible?)
      refute(find("##{bc_ele_id('western_city')}", visible: false).visible?)

      # select west, and now ease is no longer visible
      select('west', from: bc_ele_id('switcher'))
      assert(find("##{bc_ele_id('western_city')}").visible?)
      refute(find("##{bc_ele_id('eastern_city')}", visible: false).visible?)
    end
  end

  test 'weird ids like aa_b_cc work' do
    Dir.mktmpdir do |dir|
      form = <<~HEREDOC
        form:
        - aa
        - aa_b_cc
        attributes:
          aa:
            widget: select
            options:
              - [ "foo", "foo",	data-hide-aa-b-cc: true]
              - ['bar', 'bar']
          aa_b_cc:
            widget: text_field
      HEREDOC

      make_bc_app(dir, form)
      visit new_batch_connect_session_context_url('sys/app')

      # foo is default, so aa_b_cc should be hidden
      assert('foo', find("##{bc_ele_id('aa')}").value)
      refute(find("##{bc_ele_id('aa_b_cc')}", visible: false).visible?)

      # select bar, and now aa_b_cc is available.
      select('bar', from: bc_ele_id('aa'))
      assert(find("##{bc_ele_id('aa_b_cc')}").visible?)
    end
  end

  test 'radio_buttons accept scalar and array options' do
    Dir.mktmpdir do |dir|
      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - scalar
          - vector
        attributes:
          scalar:
            widget: radio_button
            options:
              - one
              - two
          vector:
            widget: radio_button
            options:
              - [Three, three]
              - [Four, four]
      HEREDOC

      make_bc_app(dir, form)
      visit new_batch_connect_session_context_url('sys/app')

      # values are all lowercase
      assert_equal('one', find("##{bc_ele_id('scalar_one')}").value)
      assert_equal('two', find("##{bc_ele_id('scalar_two')}").value)
      assert_equal('three', find("##{bc_ele_id('vector_three')}").value)
      assert_equal('four', find("##{bc_ele_id('vector_four')}").value)

      # one and two's labels are lowercase, but Three and Four have uppercase labels.
      assert_equal('one', find("[for='#{bc_ele_id('scalar_one')}']").text)
      assert_equal('two', find("[for='#{bc_ele_id('scalar_two')}']").text)
      assert_equal('Three', find("[for='#{bc_ele_id('vector_three')}']").text)
      assert_equal('Four', find("[for='#{bc_ele_id('vector_four')}']").text)
    end
  end

  test 'auto modules are case sensitive' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_MODULE_FILE_DIR: 'test/fixtures/modules' }) do
        form = <<~HEREDOC
          cluster: owens
          form:
          - auto_modules_R
          - module_hider
          attributes:
            module_hider:
              widget: select
              options:
                - ['show', 'show']
                - ['hide', 'hide',	data-hide-auto-modules-r: true]
        HEREDOC

        make_bc_app(dir, form)
        visit new_batch_connect_session_context_url('sys/app')

        # just to be sure auto_modules_r actually populates with module options
        assert_equal(20, find_all_options('auto_modules_r', nil).size)
        assert(find("##{bc_ele_id('auto_modules_r')}").visible?)

        # select hide and auto_modules_r isn't visible anymore.
        select('hide', from: bc_ele_id('module_hider'))
        refute(find("##{bc_ele_id('auto_modules_r')}", visible: :hidden).visible?)

        # select show and it's back.
        select('show', from: bc_ele_id('module_hider'))
        assert(find("##{bc_ele_id('auto_modules_r')}").visible?)
      end
    end
  end

  test 'auto modules handle nested modules' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_MODULE_FILE_DIR: 'test/fixtures/modules' }) do
        form = <<~HEREDOC
          cluster: ascend
          form:
            - auto_modules_nest-test/regular
            - auto_modules_nest-test/super
        HEREDOC

        stub_ascend
        make_bc_app(dir, form)
        visit new_batch_connect_session_context_url('sys/app')

        # super and regular variants have all the right versions
        super_opts = find_all_options('auto_modules_nest_test_super', nil).map(&:text).to_set
        assert_equal(['default', '1.0', '2.0', '3.0'].to_set, super_opts)

        regular_opts = find_all_options('auto_modules_nest_test_regular', nil).map(&:text).to_set
        assert_equal(['default', '1.0', '1.2', '1.3'].to_set, regular_opts)
      end
    end
  end

  test 'data-options-for-' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        form:
          - cluster
          - node_type
        attributes:
          cluster:
            widget: "select"
            options:
              - owens
              - pitzer
          node_type:
            widget: "select"
            options:
              - standard
              - ['gpu', 'gpu', data-option-for-cluster-pitzer: false]
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')

      # owens is selected, standard and gpu are both visible
      select('owens', from: 'batch_connect_session_context_cluster')
      options = find_all("#batch_connect_session_context_node_type option")

      assert_equal "standard", options[0]["innerHTML"]
      assert_equal '', find_option_style('node_type', 'gpu')

      # select gpu, to test that it's deselected properly when pitzer is selected
      select('gpu', from: 'batch_connect_session_context_node_type')

      # pitzer is selected, gpu is not visible
      select('pitzer', from: 'batch_connect_session_context_cluster')
      options = find_all("#batch_connect_session_context_node_type option")
      
      assert_equal "standard", options[0]["innerHTML"]
      assert_equal 'display: none;', find_option_style('node_type', 'gpu')

      # value of node_type has gone back to standard
      assert_equal 'standard', find('#batch_connect_session_context_node_type').value
    end
  end

  test 'data-option-exlusive-for-' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        form:
          - cluster
          - node_type
        attributes:
          cluster:
            widget: "select"
            options:
              - owens
              - pitzer
          node_type:
            widget: "select"
            options:
              - standard
              - ['gpu', 'gpu', data-exclusive-option-for-cluster-owens: true]
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')

      # owens is selected, standard and gpu are both visible
      select('owens', from: 'batch_connect_session_context_cluster')
      options = find_all("#batch_connect_session_context_node_type option")

      assert_equal "standard", options[0]["innerHTML"]
      assert_equal '', find_option_style('node_type', 'gpu')

      # select gpu, to test that it's deselected properly when pitzer is selected
      select('gpu', from: 'batch_connect_session_context_node_type')

      # pitzer is selected, gpu is not visible
      select('pitzer', from: 'batch_connect_session_context_cluster')
      options = find_all("#batch_connect_session_context_node_type option")

      assert_equal "standard", options[0]["innerHTML"]
      assert_equal 'display: none;', find_option_style('node_type', 'gpu')

      # value of node_type has gone back to standard
      assert_equal 'standard', find('#batch_connect_session_context_node_type').value
    end
  end

  test 'form element headers support markdown and html' do
    visit new_batch_connect_session_context_url('sys/bc_jupyter')

    # Span exists (HTML works).
    header_span = find(class: 'test_form_element_header', text: 'Some text in a span')
    # Markdown element exists (## => h2).
    markdown_header = header_span.find(:xpath, './/../../h2', text: 'Header using Markdown')
    # Header precedes its form element.
    markdown_header.first(:xpath, './/following-sibling::div').find(id: 'batch_connect_session_context_node_type')
  end

  test 'attribute headers strip script tags' do
    Dir.mktmpdir do |dir|
      "#{dir}/app".tap { |d| Dir.mkdir(d) }
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      stub_scontrol
      stub_sacctmgr
      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster: owens
        form:
          - node_type
        attributes:
          node_type:
            widget: "select"
            options:
              - standard
              - ['gpu', 'gpu', data-exclusive-option-for-cluster-owens: true]
            header: |
              <div name='node_type_header'>
                <script>window.alert('shouldnt alert');</script>
              </div>
      HEREDOC

      Pathname.new("#{dir}/app/").join('form.yml').write(form)
      base_id = 'batch_connect_session_context_path'

      visit new_batch_connect_session_context_url('sys/app')

      # this will not be text on the DOM if it's an actual <script> tag
      text = find('[name="node_type_header"]').text
      assert_equal("window.alert('shouldnt alert');", text)
    end
  end

  test 'global_bc_num_hours is same as bc_num_hours' do
    Dir.mktmpdir do |dir|
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))

      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - global_bc_num_hours
      HEREDOC

      Pathname.new("#{dir}/app/").tap { |p| FileUtils.mkdir_p(p) }.join('form.yml').write(form)
      visit(new_batch_connect_session_context_url('sys/app'))

      # the element does not have global_ prefix.
      # it's a number (default is text_field) and has the correct name.
      ele = find("##{bc_ele_id('bc_num_hours')}")
      assert_equal(ele[:type], 'number')
      assert_equal(ele[:name], 'batch_connect_session_context[bc_num_hours]')
    end
  end

  test 'global_bc_num_hours will respond to attributes if no ondemand.d config' do
    Dir.mktmpdir do |dir|
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))

      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - global_bc_num_hours
        attributes:
          global_bc_num_hours:
            min: 2
            max: 10
            value: 5
      HEREDOC

      Pathname.new("#{dir}/app/").tap { |p| FileUtils.mkdir_p(p) }.join('form.yml').write(form)
      visit(new_batch_connect_session_context_url('sys/app'))

      # the element does not have global_ prefix.
      # it's a number (default is text_field) and has the correct name.
      ele = find("##{bc_ele_id('bc_num_hours')}")
      assert_equal(ele[:type], 'number')
      assert_equal(ele[:name], 'batch_connect_session_context[bc_num_hours]')
      assert_equal(ele[:min], '2')
      assert_equal(ele[:max], '10')
      assert_equal(ele[:value], '5')
    end
  end

  test 'global_bc_num_hours will use attributes over global config' do
    Dir.mktmpdir do |dir|
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      Configuration.stubs(:config).returns({ 
        global_bc_form_items: {
          global_bc_num_hours: {
            label: 'New Label',
            min: 100,
            max: 500,
            value: 250
          }
        }
      })

      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - global_bc_num_hours
        attributes:
          global_bc_num_hours:
            min: 2
            max: 10
            value: 5
      HEREDOC

      Pathname.new("#{dir}/app/").tap { |p| FileUtils.mkdir_p(p) }.join('form.yml').write(form)
      visit(new_batch_connect_session_context_url('sys/app'))

      # the element does not have global_ prefix.
      # it's a number (default is text_field) and has the correct name.
      ele = find("##{bc_ele_id('bc_num_hours')}")
      assert_equal(ele[:type], 'number')
      assert_equal(ele[:name], 'batch_connect_session_context[bc_num_hours]')

      label = find("label[for='#{bc_ele_id('bc_num_hours')}']")

      # these values came from the attributes section of the form.yml
      assert_equal(ele[:min], '2')
      assert_equal(ele[:max], '10')
      assert_equal(ele[:value], '5')

      # but label is from the global setting.
      assert_equal(label.text, 'New Label')
    end
  end

  test 'global_bc_num_hours is bc_num_hours set globally' do
    Dir.mktmpdir do |dir|
      SysRouter.stubs(:base_path).returns(Pathname.new(dir))
      Configuration.stubs(:config).returns({ 
        global_bc_form_items: {
          global_bc_num_hours: {
            label: 'New Label',
            min: 100,
            max: 500,
            value: 250
          }
        }
      })

      stub_git("#{dir}/app")

      form = <<~HEREDOC
        ---
        cluster:
          - owens
        form:
          - global_bc_num_hours
      HEREDOC

      Pathname.new("#{dir}/app/").tap { |p| FileUtils.mkdir_p(p) }.join('form.yml').write(form)
      visit(new_batch_connect_session_context_url('sys/app'))

      # the element does not have global_ prefix.
      # it's a number (default is text_field) and has the correct name.
      ele = find("##{bc_ele_id('bc_num_hours')}")
      assert_equal(ele[:type], 'number')
      assert_equal(ele[:name], 'batch_connect_session_context[bc_num_hours]')

      label = find("label[for='#{bc_ele_id('bc_num_hours')}']")

      # these values came from the the ondemand.d configuration
      assert_equal(ele[:min], '100')
      assert_equal(ele[:max], '500')
      assert_equal(ele[:value], '250')

      # but label is from the global setting.
      assert_equal(label.text, 'New Label')
    end
  end
end
