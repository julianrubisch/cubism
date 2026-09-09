require "cable_ready"

module Cubism
  class Broadcaster
    include CableReady::Broadcaster
    include CableReady::StreamIdentifier

    attr_reader :resource

    def initialize(resource:)
      @resource = resource
    end

    def broadcast
      resource.cubicle_element_ids.to_a.each do |element_id|
        block_container = Cubism.block_store[element_id]

        next if block_container.blank?

        present_users = resource.present_users_for_element_id_and_scope(element_id, block_container.scope)

        block_source = block_container.block_source

        # Blocks declared inside an inline template are never parsed, and the
        # source store can be evicted independently of the block store. Without
        # a source there is nothing to render, and `inline: nil` would raise
        # deep inside ActionView (`nil.to_s` is frozen).
        next if block_source.nil? || block_source.source.blank?

        html = ApplicationController.render(inline: block_source.source, locals: {"#{block_source.variable_name}": present_users})

        selector = "cubicle-element#cubicle-#{element_id}[identifier='#{signed_stream_identifier(resource.to_global_id.to_s)}']"

        cable_ready[element_id].inner_html(
          selector: selector,
          html: html
        )
      end

      cable_ready.broadcast
    end
  end
end
