module CubismHelper
  include CableReady::StreamIdentifier

  def cubicle_for(resource, user, html_options: {}, appear_trigger: :connect, disappear_trigger: nil, trigger_root: nil, exclude_current_user: true, &block)
    block_location = block.source_location.join(":")

    resource_gid = resource.to_gid.to_s

    store_item = Cubism::BlockStoreItem.new(
      block_location: block_location,
      resource_gid: resource_gid,
      user_gid: user.to_gid.to_s,
      view_context: self
    )

    digested_block_key = store_item.digest

    store_item.parse!

    Cubism.store[digested_block_key] = store_item

    tag.cubicle_element(
      identifier: signed_stream_identifier(resource_gid),
      user: user.to_sgid.to_s,
      "appear-trigger": Array(appear_trigger).join(","),
      "disappear-trigger": disappear_trigger,
      "trigger-root": trigger_root,
      id: "cubicle-#{digested_block_key}",
      "exclude-current-user": exclude_current_user,
      **html_options
    )
  end
end
