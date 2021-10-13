module CubismHelper
  include CableReady::StreamIdentifier

  def cubicle_for(resource, html_options: {}, &block)
    template = capture(&block)

    tag.cubicle_element({identifier: signed_stream_identifier(resource.to_global_id.to_s)}) do
      content_tag(:template, template, {slot: "template"})
    end
  end
end
