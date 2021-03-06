require "test_helper"

class Cubism::PresenceChannelTest < ActionCable::Channel::TestCase
  include CableReady::StreamIdentifier

  setup do
    @post = posts(:one)
    @user = users(:one)

    Post.any_instance.stubs(:cubicle_element_ids).returns([])
    Post.any_instance.stubs(:excluded_user_id_for_element_id).returns({})
    Post.any_instance.stubs(:present_users).returns({})

    Cubism.stubs(:block_store).returns({
      "foo" => Cubism::BlockContainer.new(block_location: "test:1", user_gid: @user.to_gid.to_s, resource_gid: @post.to_gid.to_s, scope: ""),
      "bar" => Cubism::BlockContainer.new(block_location: "test:1", user_gid: @user.to_gid.to_s, resource_gid: @post.to_gid.to_s, scope: "edit")
    })
  end

  test "rejects a subscription for invalid identifiers" do
    subscribe identifier: "foo", element_id: "cubicle-bar"

    assert subscription.rejected?
  end

  test "confirms a subscription for valid identifiers" do
    subscribe identifier: signed_stream_identifier(@post.to_gid.to_s), element_id: "cubicle-bar"

    assert subscription.confirmed?

    assert_has_stream "bar"
    assert_equal 1, @post.cubicle_element_ids.size
  end

  test "adds user_id to the excluded users hash if the exclude_current_user param is passed" do
    subscribe identifier: signed_stream_identifier(@post.to_gid.to_s), element_id: "cubicle-bar", exclude_current_user: true

    assert_equal({"bar" => @user.id}, @post.excluded_user_id_for_element_id)
  end

  test "adds a user to the present users list when appear is called" do
    subscribe identifier: signed_stream_identifier(@post.to_gid.to_s), element_id: "cubicle-foo"
    perform :appear

    assert_equal [@user.id], @post.present_users_for_scope("").to_a
  end

  test "adds a user to a scope in the present users list when appear is called with a scope parameter" do
    assert_equal [], @post.present_users_for_scope("edit").to_a
    assert_equal [], @post.present_users_for_scope("show").to_a

    subscribe identifier: signed_stream_identifier(@post.to_gid.to_s), element_id: "cubicle-bar", scope: "edit"
    perform :appear

    subscribe identifier: signed_stream_identifier(@post.to_gid.to_s), element_id: "bar", scope: "show"

    assert_equal [@user.id], @post.present_users_for_scope("edit").to_a
    assert_equal [], @post.present_users_for_scope("show").to_a
  end

  test "removes a user from the present users list when disappear is called" do
    subscribe identifier: signed_stream_identifier(@post.to_gid.to_s), element_id: "cubicle-foo"

    perform :appear

    assert_equal [@user.id], @post.present_users_for_scope("").to_a

    perform :disappear

    assert_equal [], @post.present_users_for_scope("").to_a
  end
end
