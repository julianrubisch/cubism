module CubismHelper
  include CableReady::StreamIdentifier

  def cubicle_for(resource, user, html_options: {}, appear_trigger: :connect, disappear_trigger: nil, trigger_root: nil, exclude_current_user: true, &block)
    block_key = block.source_location.join(":")
    resource_user_key = "#{resource.to_gid}:#{user.to_gid}"
    digested_block_key = ActiveSupport::Digest.hexdigest(block_key)
    digested_user_resource_key = ActiveSupport::Digest.hexdigest(resource_user_key)

    Cubism.store[digested_block_key] = Cubism::BlockStoreItem.new(context: self, block: block.dup)
    tag.cubicle_element(
      identifier: signed_stream_identifier(resource.to_gid.to_s),
      user: user.to_sgid.to_s,
      "appear-trigger": Array(appear_trigger).join(","),
      "disappear-trigger": disappear_trigger,
      "trigger-root": trigger_root,
      id: "cubicle-#{digested_block_key}-#{digested_user_resource_key}",
      "exclude-current-user": exclude_current_user,
      **html_options
    )
  end
end
