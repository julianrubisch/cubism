module CubismHelper
  include CableReady::StreamIdentifier

  def cubicle_for(resource, user, html_options: {}, trigger: :connect, exclude_current_user: true, &block)
    template = capture(&block)

    tag.cubicle_element(
      identifier: signed_stream_identifier(resource.to_global_id.to_s),
      user: user.to_sgid.to_s,
      trigger: trigger,
      id: "cubicle-#{SecureRandom.alphanumeric(16)}",
      "exclude-current-user": exclude_current_user,
      **html_options
    ) do
      content_tag(:template, template, {slot: "template"})
    end
  end
end
