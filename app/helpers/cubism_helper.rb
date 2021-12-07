module CubismHelper
  include CableReady::StreamIdentifier

  def cubicle_for(resource, user, html_options: {}, appear_trigger: :connect, disappear_trigger: nil, trigger_root: nil, exclude_current_user: true, &block)
    key = "#{block.source_location.join(":")}:#{resource.to_gid}:#{user.to_gid}"
    verifiable_id = CableReady.signed_stream_verifier.generate(key)

    Cubism.store[verifiable_id] = block.dup
    template = capture(&block)

    tag.cubicle_element(
      identifier: signed_stream_identifier(resource.to_gid.to_s),
      user: user.to_sgid.to_s,
      "appear-trigger": appear_trigger,
      "disappear-trigger": disappear_trigger,
      "trigger-root": trigger_root,
      id: "cubicle-#{verifiable_id}",
      "exclude-current-user": exclude_current_user,
      **html_options
    ) do
      content_tag(:template, template, {slot: "template"})
    end
  end
end
