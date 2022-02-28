require "test_helper"

class BroadcasterTest < ActionView::TestCase
  include CableReady::StreamIdentifier

  setup do
    @post = posts(:one)
    @post.stubs(:cubicle_element_ids).returns(%w[foo bar])
    @post.stubs(:present_users_for_element_id_and_scope).with("foo", "").returns([users(:one)])
    @post.stubs(:present_users_for_element_id_and_scope).with("bar", "").returns([users(:two)])

    @post_2 = posts(:two)
    @post_2.stubs(:cubicle_element_ids).returns(%w[baz])
    @post_2.stubs(:present_users_for_element_id_and_scope).with("baz", :edit).returns([users(:one)])
    @post_2.stubs(:present_users_for_element_id_and_scope).with("baz", :show).returns([])

    block_source_foo = Cubism::BlockSource.new(location: "test:1", variable_name: "users", source: "<div><%= users.map(&:username).to_sentence %></div>", view_context: self)
    block_source_bar = Cubism::BlockSource.new(location: "test:1", variable_name: "present_users", source: "<div><%= present_users.map(&:username).to_sentence %></div>", view_context: self)

    Cubism.stubs(:block_store).returns({
      "foo" => Cubism::BlockContainer.new(block_location: "test:1", block_source: block_source_foo, user_gid: users(:one).to_gid.to_s, resource_gid: posts(:one).to_gid.to_s),
      "bar" => Cubism::BlockContainer.new(block_location: "test:1", block_source: block_source_bar, user_gid: users(:two).to_gid.to_s, resource_gid: posts(:one).to_gid.to_s),
      "baz" => Cubism::BlockContainer.new(block_location: "test:1", block_source: block_source_foo, user_gid: users(:one).to_gid.to_s, resource_gid: posts(:two).to_gid.to_s, scope: :edit)
    })
  end

  test "it broadcasts to all registered element ids with default scopes" do
    with_mocked_cable_ready({"foo" => {"" => users(:one)}, "bar" => {"" => users(:two)}}, @post) do |cable_ready_mock|
      @broadcaster = Cubism::Broadcaster.new(resource: @post)

      @broadcaster.expects(:cable_ready).returns(cable_ready_mock).times(3)

      @broadcaster.broadcast
    end
  end

  test "it broadcasts to all registered element ids and respects scopes" do
    with_mocked_cable_ready({"baz" => {"edit" => users(:one)}}, @post_2) do |cable_ready_mock|
      @broadcaster = Cubism::Broadcaster.new(resource: @post_2)

      @broadcaster.expects(:cable_ready).returns(cable_ready_mock).twice

      @broadcaster.broadcast
    end
  end
end

def with_mocked_cable_ready(elements_with_users_and_scopes, resource)
  cable_ready_mock = mock
  cable_ready_mock.expects(:broadcast).once

  elements_with_users_and_scopes.each do |element_id, scoped_users|
    cable_ready_channel = mock
    scoped_users.each do |scope, user|
      cable_ready_channel
        .expects(:inner_html)
        .with({
          selector: "cubicle-element#cubicle-#{element_id}[identifier='#{signed_stream_identifier(resource.to_global_id.to_s)}'][scope='#{scope}']",
          html: "<div>#{user.username}</div>"
        })
    end
    cable_ready_mock.expects(:[]).with(element_id).returns(cable_ready_channel)
  end

  yield cable_ready_mock
end
