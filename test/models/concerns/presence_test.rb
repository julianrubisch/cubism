require "test_helper"

class Cubism::PresenceTest < ActiveSupport::TestCase
  setup do
    scoped_present_users = {
      "" => Marshal.dump(Set.new([users(:one).id, users(:two).id])),
      :edit => Marshal.dump(Set.new([users(:one).id])),
      :show => Marshal.dump(Set.new([users(:two).id]))
    }

    @post = posts(:one)
    @post.stubs(:present_users).returns(scoped_present_users)
    @post.stubs(:excluded_user_id_for_element_id).returns({"foo" => users(:one).id, "bar" => users(:two).id})
  end

  test "Cubism::Presence respects excluded users per element" do
    assert_equal [users(:two)], @post.present_users_for_element_id_and_scope("foo")
    assert_equal [users(:one)], @post.present_users_for_element_id_and_scope("bar")
  end

  test "Cubism::Presence respects scopes along with excluded users" do
    assert_equal [users(:one)], @post.present_users_for_element_id_and_scope("bar", :edit)
    assert_equal [], @post.present_users_for_element_id_and_scope("bar", :show)
  end
end
