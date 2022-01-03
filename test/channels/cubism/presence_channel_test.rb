require "test_helper"

class Cubism::PresenceChannelTest < ActionCable::Channel::TestCase
  include CableReady::StreamIdentifier

  setup do
    @post = posts(:one)
    @user = users(:one)

    Post.any_instance.stubs(:cubicle_element_ids).returns([])
    Post.any_instance.stubs(:excluded_user_id_for_element_id).returns({})
    Post.any_instance.stubs(:present_users).returns(Set[])
  end

  test "rejects a subscription for invalid identifiers" do
    subscribe identifier: "foo", element_id: "bar"

    assert subscription.rejected?
  end

  test "confirms a subscription for valid identifiers" do
    subscribe identifier: signed_stream_identifier(@post.to_gid.to_s), element_id: "bar"

    assert subscription.confirmed?

    assert_has_stream "bar"
    assert_equal 1, @post.cubicle_element_ids.size
  end

  test "adds user_id to the excluded users hash if the exclude_current_user param is passed" do
    subscribe identifier: signed_stream_identifier(@post.to_gid.to_s), user: @user.to_sgid.to_s, element_id: "bar", exclude_current_user: true

    assert_equal({"bar" => @user.id}, @post.excluded_user_id_for_element_id)
  end

  test "adds a user to the present users list when appear is called" do
    subscribe identifier: signed_stream_identifier(@post.to_gid.to_s), user: @user.to_sgid.to_s, element_id: "bar"

    perform :appear

    assert_equal [@user.id], @post.present_users.to_a
  end

  test "removes a user from the present users list when appear is called" do
    subscribe identifier: signed_stream_identifier(@post.to_gid.to_s), user: @user.to_sgid.to_s, element_id: "bar"

    perform :appear

    assert_equal [@user.id], @post.present_users.to_a

    # perform :disappear

    # assert_equal [], @post.present_users.to_a
  end
end
