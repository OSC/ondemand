require 'test_helper'

class OodAppGroupTest < ActiveSupport::TestCase

  def app(title, category, subcategory)
    OpenStruct.new(title: title, category: category, subcategory: subcategory, metadata: {})
  end

  def build_apps(category, subcategory, titles)
    titles.map { |title| app(title, category, subcategory) }
  end

  # test grouping apps for navbar
  # FIXME: this might be better in another file
  test "apps sorted by category and subcategory" do
    apps = []
    apps.concat(build_apps("Desktops", "IHPC", ["Abaqus/CAE", "ANSYS Workbench", "COMSOL", "Oakley Desktop", "Ruby Desktop"] ))
    apps.concat(build_apps("Desktops", "VDI", ["Oakley VDI", "Ruby VDI", "Paraview"] ))
    apps.concat(build_apps("Clusters", "", ["Shell Access", "System Status"]))
    apps.concat(build_apps("Jobs", "", ["My Jobs", "Active Jobs"] ))
    apps.concat(build_apps("Files", "", ["Files"] ))
    apps.concat(build_apps("OSC WIAG", "", ["Container Fill Sim"] ))
    apps.shuffle!

    # group unsorted list of apps by category
    groups = OodAppGroup.groups_for(apps: apps)
    assert_equal 5, groups.count
    assert_equal "Clusters", groups.first.title
    assert_equal "OSC WIAG", groups.last.title

    # select a subset of groups and verify order
    nav_group_titles = ["Files", "Jobs", "Clusters", "Desktops"]
    groups2 = OodAppGroup.select(titles: nav_group_titles, groups: groups)
    assert_equal 4, groups2.count
    assert_equal nav_group_titles, groups2.map(&:title)

    # if a group specified doesn't exist, omit it
    groups2 = OodAppGroup.select(titles: nav_group_titles + ["Other"], groups: groups)
    assert_equal 4, groups2.count
    assert_equal nav_group_titles, groups2.map(&:title)

    # if a group specified doesn't exist, omit it
    groups2 = OodAppGroup.select(titles: ["Other"] + nav_group_titles, groups: groups)
    assert_equal 4, groups2.count
    assert_equal nav_group_titles, groups2.map(&:title)
  end


  test "group by subcategory" do
    apps = []
    apps.concat(build_apps("Desktops", "IHPC", ["Abaqus/CAE", "ANSYS Workbench", "COMSOL", "Oakley Desktop", "Ruby Desktop"] ))
    apps.concat(build_apps("Desktops", "VDI", ["Oakley VDI", "Ruby VDI", "Paraview"] ))
    apps.concat(build_apps("Desktops", "", ["Desktop App With No Subcat"]))
    apps.concat(build_apps("Clusters", "", ["Shell Access", "System Status"]))
    apps.shuffle!

    groups = OodAppGroup.groups_for(apps: apps)
    assert_equal 2, groups.count
    assert_equal "Desktops", groups.last.title

    desktops = groups.last
    subgroups = OodAppGroup.groups_for(apps: desktops.apps, group_by: :subcategory)
    assert_equal 3, subgroups.count
    assert_equal "IHPC", subgroups[0].title
    assert_equal 5, subgroups[0].apps.count
    assert_equal "VDI", subgroups[1].title
    assert_equal 3, subgroups[1].apps.count
    assert_equal "", subgroups[2].title
    assert_equal 1, subgroups[2].apps.count

    # test selecting a set of subgroups
    subgroups2 = OodAppGroup.select(titles: ["VDI", "IHPC"], groups: subgroups)
    assert_equal 2, subgroups2.count
    assert_equal "VDI", subgroups2[0].title
    assert_equal "IHPC", subgroups2[1].title
  end

  test "group nav_limit" do
    assert_equal 6, OodAppGroup.new(nav_limit: 6).nav_limit
  end

  test "group nav_limit set for each group when setting in .groups_for" do
    apps = []
    apps.concat(build_apps("Desktops", "IHPC", ["Abaqus/CAE", "ANSYS Workbench", "COMSOL", "Oakley Desktop", "Ruby Desktop"] ))
    apps.concat(build_apps("Desktops", "VDI", ["Oakley VDI", "Ruby VDI", "Paraview"] ))
    assert_equal 6, OodAppGroup.groups_for(apps: apps, nav_limit: 6).first.nav_limit
  end

  test "ungroupable apps" do
    apps = []
    apps.concat(build_apps("Desktops", "IHPC", ["Abaqus/CAE", "ANSYS Workbench", "COMSOL", "Oakley Desktop", "Ruby Desktop"] ))
    apps.concat(build_apps("Desktops", "VDI", ["Oakley VDI", "Ruby VDI", "Paraview"] ))
    apps.concat(build_apps("Clusters", "", ["Shell Access", "System Status"]))
    apps.concat(build_apps("Jobs", "", ["My Jobs", "Active Jobs"] ))
    apps.concat(build_apps("Files", "", ["Files"] ))
    apps.concat(build_apps("OSC WIAG", "", ["Container Fill Sim"] ))
    apps.shuffle!

    groups = OodAppGroup.groups_for(apps: apps, group_by: :user_defined_field)
    assert_equal 1, groups.size
    assert_equal 14, groups.first.apps.size
    assert_nil groups.first.title
  end

  test "group by metadata field" do
    app_dir = Pathname.new("#{Rails.root}/test/fixtures/sys_with_gateway_apps")
    apps = app_dir.children.map { |d| OodApp.new PathRouter.new(d) }

    groups = OodAppGroup.groups_for(apps: apps, group_by: :languages)

    assert_equal 3, groups.size
    assert_equal "go erLANG python", groups[0].title
    assert_equal 1, groups[0].apps.count
    assert_equal "python julia R Ruby", groups[1].title
    assert_equal 1, groups[1].apps.count

    # groups with a nil title are last
    assert_nil groups[2].title
    assert_equal 10, groups[2].apps.count
  end

  test "OodAppGroup.order should sort groups based on titles array" do
    titles = ["title1", "title2"]
    group1 = OodAppGroup.new(title: "title1")
    group2 = OodAppGroup.new(title: "title2")
    group3 = OodAppGroup.new(title: "title3")

    result = OodAppGroup.order(titles: titles, groups: [group3, group2, group1])

    assert_equal [group1, group2, group3], result
  end

  test "OodAppGroup.order should not modify titles or groups array" do
    titles = ["title1", "title2"]
    group1 = OodAppGroup.new(title: SecureRandom.uuid)
    group2 = OodAppGroup.new(title: SecureRandom.uuid)
    groups = [group1, group2]

    OodAppGroup.order(titles: titles, groups: groups)

    assert_equal ["title1", "title2"], titles
    assert_equal [group1, group2], groups
  end

  test "group icon_uri default" do
    assert_nil OodAppGroup.new.icon_uri
  end

  test "group icon_uri" do
    assert_equal URI("fas://desktop"), OodAppGroup.new(icon_uri: "fas://desktop").icon_uri
  end

end
