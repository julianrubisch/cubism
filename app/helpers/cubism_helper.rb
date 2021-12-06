module CubismHelper
  include CableReady::StreamIdentifier

  def cubicle_for(resource, user, html_options: {}, trigger: :connect, &block)
    template = capture(&block)

    tag.cubicle_element(identifier: signed_stream_identifier(resource.to_global_id.to_s), user: user.to_sgid.to_s, trigger: trigger, **html_options) do
      content_tag(:template, template, {slot: "template"})
    end
  end
end
