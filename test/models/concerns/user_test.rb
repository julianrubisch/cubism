require "test_helper"

class Cubism::UserTest < ActiveSupport::TestCase
  test "Cubism::User registers global Cubism.user_class upon inclusion" do
    user = users(:one)

    assert_equal Cubism.user_class, user.class
  end
end
