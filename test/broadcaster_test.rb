require "test_helper"

class BroadcasterTest < ActionView::TestCase
  include CableReady::StreamIdentifier

  setup do
    @post = posts(:one)
    @post.stubs(:cubicle_element_ids).returns(%w[cubicle-foo cubicle-bar])
    @post.stubs(:present_users_for_element_id).with("cubicle-foo").returns([users(:one)])
    @post.stubs(:present_users_for_element_id).with("cubicle-bar").returns([users(:two)])
    @broadcaster = Cubism::Broadcaster.new(resource: @post)

    Cubism.stubs(:store).returns({
      "foo" => Cubism::BlockStoreItem.new(block_location: "test:1", block_source: "<div><%= users.map(&:username).to_sentence %></div>", block_variable_name: "users", user_gid: users(:one).to_gid.to_s, resource_gid: posts(:one).to_gid.to_s),
      "bar" => Cubism::BlockStoreItem.new(block_location: "test:1", block_source: "<div><%= present_users.map(&:username).to_sentence %></div>", block_variable_name: "present_users", user_gid: users(:two).to_gid.to_s, resource_gid: posts(:one).to_gid.to_s)
    })
  end

  test "it broadcasts to all registered element ids" do
    with_mocked_cable_ready({"cubicle-foo" => users(:one), "cubicle-bar" => users(:two)}, @post) do |cable_ready_mock|
      members = Set[]
      members.stubs(:members).returns([users(:one).id, users(:two).id])
      @post.stubs(:present_users).returns(members)

      @broadcaster.expects(:cable_ready).returns(cable_ready_mock).twice

      @broadcaster.broadcast
    end
  end
end

def with_mocked_cable_ready(elements_with_users, resource)
  operation_mock = mock
  operation_mock.expects(:broadcast).times(elements_with_users.size)

  cable_ready_mock = mock

  elements_with_users.each do |element_id, user|
    cable_ready_channel = mock
    cable_ready_channel
      .expects(:inner_html)
      .with({
        selector: "cubicle-element##{element_id}[identifier='#{signed_stream_identifier(resource.to_global_id.to_s)}']",
        html: "<div>#{user.username}</div>"
      })
      .returns(operation_mock)
    cable_ready_mock.expects(:[]).with(element_id).returns(cable_ready_channel)
  end

  yield cable_ready_mock
end
