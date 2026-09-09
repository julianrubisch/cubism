module CubismHelper
  include CableReady::StreamIdentifier

  def cubicle_for(resource, user, scope: "", html_options: {}, appear_trigger: :connect, disappear_trigger: nil, trigger_root: nil, exclude_current_user: true, &block)
    return if Cubism.skip_in_test? && Rails.env.test?

    block_location = block.source_location.join(":")
    block_source = Cubism::BlockSource.find_or_create(
      location: block_location,
      view_context: self
    )
    if block_source.variable_name.blank?
      block_variable_name = block.parameters.find { |type, _| [:req, :opt, :rest].include?(type) }&.last
      if block_variable_name.present?
        block_source.variable_name = block_variable_name.to_s
        # Never write back a sourceless block source: it would replace a good
        # store entry with one the broadcaster cannot render.
        Cubism.source_store[block_source.digest] = block_source if block_source.source.present?
      end
    end

    resource_gid = resource.to_gid.to_s

    block_container = Cubism::BlockContainer.new(
      block_location: block_location,
      block_source: block_source,
      resource_gid: resource_gid,
      user_gid: user.to_gid.to_s,
      scope: scope
    )

    digested_block_key = block_container.digest

    Cubism.block_store.fetch(digested_block_key, block_container)

    tag.cubicle_element(
      identifier: signed_stream_identifier(resource_gid),
      "appear-trigger": Array(appear_trigger).join(","),
      "disappear-trigger": disappear_trigger,
      "trigger-root": trigger_root,
      id: "cubicle-#{digested_block_key}",
      "exclude-current-user": exclude_current_user,
      **html_options
    )
  end
end
