module CubismHelper
  include CableReady::StreamIdentifier

  def cubicle_for(resource, user, html_options: {}, subscribe_trigger: :connect, unsubscribe_trigger: nil, trigger_root: nil, exclude_current_user: true, &block)
    template = capture(&block)

    tag.cubicle_element(
      identifier: signed_stream_identifier(resource.to_global_id.to_s),
      user: user.to_sgid.to_s,
      "subscribe-trigger": subscribe_trigger,
      "unsubscribe-trigger": unsubscribe_trigger,
      "trigger-root": trigger_root,
      id: "cubicle-#{SecureRandom.alphanumeric(16)}",
      "exclude-current-user": exclude_current_user,
      **html_options
    ) do
      content_tag(:template, template, {slot: "template"})
    end
  end
end
