require "test_helper"

class StoreItemTest < ActiveSupport::TestCase
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

  test "digest changes when file contents change" do
    template = "fixtures/_cubicle_partial"

    digest1 = Cubism::BlockStoreItem.new(
      block_location: "#{template_tmp_path(template)}.html.erb:1",
      resource_gid: @post.to_gid.to_s,
      user_gid: @user.to_gid.to_s
    ).digest

    change_template(template)

    digest2 = Cubism::BlockStoreItem.new(
      block_location: "#{template_tmp_path(template)}.html.erb:1",
      resource_gid: @post.to_gid.to_s,
      user_gid: @user.to_gid.to_s
    ).digest

    refute_equal digest1, digest2
  end

  test "digest changes when user changes" do
    template = "fixtures/_cubicle_partial"

    digest1 = Cubism::BlockStoreItem.new(
      block_location: "#{template_tmp_path(template)}.html.erb:1",
      resource_gid: @post.to_gid.to_s,
      user_gid: @user.to_gid.to_s
    ).digest

    digest2 = Cubism::BlockStoreItem.new(
      block_location: "#{template_tmp_path(template)}.html.erb:1",
      resource_gid: @post.to_gid.to_s,
      user_gid: users(:two).to_gid.to_s
    ).digest

    refute_equal digest1, digest2
  end

  test "digest changes when resource changes" do
    template = "fixtures/_cubicle_partial"

    digest1 = Cubism::BlockStoreItem.new(
      block_location: "#{template_tmp_path(template)}.html.erb:1",
      resource_gid: @post.to_gid.to_s,
      user_gid: @user.to_gid.to_s
    ).digest

    digest2 = Cubism::BlockStoreItem.new(
      block_location: "#{template_tmp_path(template)}.html.erb:1",
      resource_gid: posts(:two).to_gid.to_s,
      user_gid: @user.to_gid.to_s
    ).digest

    refute_equal digest1, digest2
  end

  test "digest changes when block_location changes" do
    template = "fixtures/_cubicle_partial"

    digest1 = Cubism::BlockStoreItem.new(
      block_location: "#{template_tmp_path(template)}.html.erb:1",
      resource_gid: @post.to_gid.to_s,
      user_gid: @user.to_gid.to_s
    ).digest

    digest2 = Cubism::BlockStoreItem.new(
      block_location: "#{template_tmp_path(template)}.html.erb:2",
      resource_gid: @post.to_gid.to_s,
      user_gid: @user.to_gid.to_s
    ).digest

    refute_equal digest1, digest2
  end

  private

  def template_tmp_path(template)
    Pathname.new(@tmp_dir).join(template).to_path
  end

  def change_template(template)
    File.write("#{template}.html.erb", "\nTHIS WAS CHANGED!")
  end
end
