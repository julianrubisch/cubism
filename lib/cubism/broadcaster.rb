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
        /cubicle-(?<block_key>.+)/ =~ element_id
        next if Cubism.store[block_key].blank?

        block = Cubism.store[block_key].block
        view_context = Cubism.store[block_key].context
        html = view_context.capture(resource.present_users_for_element_id(element_id), &block)

        cable_ready[element_id].inner_html(
          selector: "cubicle-element##{element_id}[identifier='#{signed_stream_identifier(resource.to_global_id.to_s)}']",
          html: html
        ).broadcast
      end
    end
  end
end
