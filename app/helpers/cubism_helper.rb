module CubismHelper
  include CableReady::Compoundable
  include CableReady::StreamIdentifier

  def cubicle_for(*keys, html_options: {})
    tag.cubicle_element({identifier: signed_stream_identifier(compound(keys))})
  end
end
