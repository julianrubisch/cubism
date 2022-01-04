require "test_helper"

class Cubism::PresenceTest < ActiveSupport::TestCase
  setup do
    members = Set[]
    members.stubs(:members).returns([users(:one).id, users(:two).id])

    @post = posts(:one)
    @post.stubs(:present_users).returns(members)
    @post.stubs(:excluded_user_id_for_element_id).returns({"foo" => users(:one).id, "bar" => users(:two).id})
  end

  test "Cubism::Presence respects excluded users per element" do
    assert_equal [users(:two)], @post.present_users_for_element_id("foo")
    assert_equal [users(:one)], @post.present_users_for_element_id("bar")
  end
end
