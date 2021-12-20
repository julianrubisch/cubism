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
        block = Cubism.store[block_key].block
        view_context = Cubism.store[block_key].context
        html = view_context.capture(users_for(resource, element_id), &block)

        cable_ready[element_id].inner_html(
          selector: "cubicle-element##{element_id}[identifier='#{signed_stream_identifier(resource.to_global_id.to_s)}']",
          html: html
        ).broadcast
      end
    end

    private

    def users_for(resource, element_id)
      users = Cubism.user_class.find(resource.present_users.members)
      users.reject! { |user| user.id == resource.excluded_user_id_for_element_id[element_id].to_i }

      users
    end
  end
end
