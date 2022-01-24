module CubismHelper
  include CableReady::StreamIdentifier

  def cubicle_for(resource, user, html_options: {}, appear_trigger: :connect, disappear_trigger: nil, trigger_root: nil, exclude_current_user: true, &block)
    filename, lineno = block.source_location
    block_location = block.source_location.join(":")
    resource_user_key = "#{resource.to_gid}:#{user.to_gid}"
    digested_block_key = ActiveSupport::Digest.hexdigest("#{block_location}:#{resource_user_key}")

    # the store item (identified by block location, resource, and user) might already be present
    store_item = Cubism.store[digested_block_key] || Cubism::BlockStoreItem.new(
      block_location: block_location,
      resource_gid: resource.to_gid.to_s,
      user_gid: user.to_gid.to_s
    )

    if Cubism.store[digested_block_key]&.block_source.blank? && !block_location.start_with?("inline template")
      lines = File.readlines(filename)[lineno - 1..]

      preprocessor = Cubism::Preprocessor.new(source: lines.join.squish, view_context: self)
      store_item.block_source = preprocessor.process
    end

    Cubism.store[digested_block_key] = store_item

    tag.cubicle_element(
      identifier: signed_stream_identifier(resource.to_gid.to_s),
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
