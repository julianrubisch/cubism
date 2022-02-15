require "test_helper"

class BlockSourceTest < ActionView::TestCase
  FIXTURES_DIR = File.expand_path("./fixtures", __dir__)

  setup do
    @cwd = Dir.pwd
    @tmp_dir = Dir.mktmpdir

    FileUtils.cp_r FIXTURES_DIR, @tmp_dir
    Dir.chdir @tmp_dir

    @post = posts(:one)
    @user = users(:one)
  end

  teardown do
    Dir.chdir @cwd
    FileUtils.rm_r @tmp_dir
  end

  test "block source digest changes when file contents change" do
    template = "fixtures/_cubicle_partial"

    digest1 = Cubism::BlockSource.new(
      location: "#{template_tmp_path(template)}.html.erb:1",
      view_context: self
    ).digest

    change_template(template)

    digest2 = Cubism::BlockSource.new(
      location: "#{template_tmp_path(template)}.html.erb:1",
      view_context: self
    ).digest

    refute_equal digest1, digest2
  end

  test "block source digest changes when block_location changes" do
    template = "fixtures/_cubicle_partial"

    digest1 = Cubism::BlockSource.new(
      location: "#{template_tmp_path(template)}.html.erb:1",
      view_context: self
    ).digest

    digest2 = Cubism::BlockSource.new(
      location: "#{template_tmp_path(template)}.html.erb:2",
      view_context: self
    ).digest

    refute_equal digest1, digest2
  end

  test "can be created in the store by source location" do
    template = "fixtures/_cubicle_partial"

    assert_equal 0, Cubism.source_store.size

    Cubism::BlockSource.any_instance.expects(:parse!).once

    Cubism::BlockSource.find_or_create(
      location: "#{template_tmp_path(template)}.html.erb:1",
      view_context: self
    )

    assert_equal 1, Cubism.source_store.size
  end

  test "existing block source is returned and not parsed" do
    template = "fixtures/_cubicle_partial"

    instance = Cubism::BlockSource.new(
      location: "#{template_tmp_path(template)}.html.erb:1",
      view_context: self
    )

    Cubism.source_store[instance.digest] = instance

    assert_equal 1, Cubism.source_store.size

    Cubism::BlockSource.any_instance.expects(:parse!).never

    Cubism::BlockSource.find_or_create(
      location: "#{template_tmp_path(template)}.html.erb:1",
      view_context: self
    )

    assert_equal 1, Cubism.source_store.size
  end

  private

  def template_tmp_path(template)
    Pathname.new(@tmp_dir).join(template).to_path
  end

  def change_template(template)
    File.write("#{template}.html.erb", "\nTHIS WAS CHANGED!")
  end
end
