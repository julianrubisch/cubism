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
        store_item = Cubism.block_store[block_key]

        next if store_item.blank?

        html = ApplicationController.render(inline: store_item.block_source, locals: {"#{store_item.block_variable_name}": resource.present_users_for_element_id(element_id)})

        cable_ready[element_id].inner_html(
          selector: "cubicle-element##{element_id}[identifier='#{signed_stream_identifier(resource.to_global_id.to_s)}']",
          html: html
        ).broadcast
      end
    end
  end
end
