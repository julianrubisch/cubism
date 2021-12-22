module CubismHelper
  include CableReady::StreamIdentifier

  def cubicle_for(resource, user, html_options: {}, appear_trigger: :connect, disappear_trigger: nil, trigger_root: nil, exclude_current_user: true, &block)
    key = "#{block.source_location.join(":")}:#{resource.to_gid}:#{user.to_gid}"
    digested_id = ActiveSupport::Digest.hexdigest(key)

    Cubism.store[digested_id] = Cubism::BlockStoreItem.new(context: self, block: block.dup)
    tag.cubicle_element(
      identifier: signed_stream_identifier(resource.to_gid.to_s),
      user: user.to_sgid.to_s,
      "appear-trigger": Array(appear_trigger).join(","),
      "disappear-trigger": disappear_trigger,
      "trigger-root": trigger_root,
      id: "cubicle-#{digested_id}",
      "exclude-current-user": exclude_current_user,
      **html_options
    )
  end
end
