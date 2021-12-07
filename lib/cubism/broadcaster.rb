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
        cable_ready[Cubism::PresenceChannel].dispatch_event(
          name: "cubism:update",
          selector: "cubicle-element##{element_id}[identifier='#{signed_stream_identifier(resource.to_global_id.to_s)}']",
          detail: {
            users: users_for(resource, element_id)
          }
        ).broadcast_to(resource)
      end
    end

    private

    def users_for(resource, element_id)
      users = Cubism.user_class.find(resource.present_users.members)
      users.reject! { |user| user.id == resource.excluded_user_id_for_element_id[element_id].to_i }

      users.map { |user| user.slice(user.cubicle_attributes) }.as_json
    end
  end
end
