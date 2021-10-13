class Cubism::StreamPresenceJob < ApplicationJob
  include CableReady::Broadcaster
  include CableReady::StreamIdentifier
  queue_as :default

  def perform(resource:)
    cable_ready[Cubism::PresenceChannel].dispatch_event(
      name: "cubism:update",
      selector: "cubicle-element[identifier='#{signed_stream_identifier(resource.to_global_id.to_s)}']",
      detail: {
        users: Cubism.user_class.find(resource.present_users.members).map { |user| user.slice(user.cubicle_attributes) }.as_json
      }
    ).broadcast_to(resource)
  end
end
