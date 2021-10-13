class Cubism::StreamPresenceJob < ApplicationJob
  include CableReady::Broadcaster
  queue_as :default

  def perform(resource:)
    cable_ready[Cubism::PresenceChannel].outer_html(
      selector: dom_id(resource, "cubicle").to_s,
      html: ApplicationController.render(partial: "shared/presence_indicator", locals: {users: User.where(id: resource.present_users.members)})
    ).broadcast
  end
end
