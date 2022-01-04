require "test_helper"

class BroadcasterTest < ActionView::TestCase
  setup do
    @post = posts(:one)
    @post.stubs(:cubicle_element_ids).returns(%w[cubicle-foo cubicle-bar])
    @post.stubs(:present_users_for_element_id).with("cubicle-foo").returns([users(:one)])
    @post.stubs(:present_users_for_element_id).with("cubicle-bar").returns([users(:two)])
    @broadcaster = Cubism::Broadcaster.new(resource: @post)

    @foo_user_list = []
    @bar_user_list = []

    Cubism.stubs(:store).returns({
      "foo" => Cubism::BlockStoreItem.new(context: view, block: ->(users) { @foo_user_list = users }),
      "bar" => Cubism::BlockStoreItem.new(context: view, block: ->(users) { @bar_user_list = users })
    })
  end

  test "it broadcasts to all registered element ids" do
    with_mocked_cable_ready(%w[cubicle-foo cubicle-bar]) do |cable_ready_mock|
      members = Set[]
      members.stubs(:members).returns([users(:one).id])
      @post.stubs(:present_users).returns(members)

      @broadcaster.expects(:cable_ready).returns(cable_ready_mock).twice

      @broadcaster.broadcast

      assert_equal [users(:one)], @foo_user_list
      assert_equal [users(:two)], @bar_user_list
    end
  end
end

def with_mocked_cable_ready(element_ids)
  operation_mock = mock
  operation_mock.expects(:broadcast).times(element_ids.size)
  cable_ready_channel = mock
  cable_ready_channel.expects(:inner_html).returns(operation_mock).times(element_ids.size)
  cable_ready_mock = mock

  element_ids.each do |element_id|
    cable_ready_mock.expects(:[]).with(element_id).returns(cable_ready_channel)
  end

  yield cable_ready_mock
end
