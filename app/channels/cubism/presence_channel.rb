class Cubism::PresenceChannel < ApplicationCable::Channel
  def subscribed
    resource = GlobalID::Locator.locate_signed params[:signed_resource]
    if resource.present?
      stream_from "presence:#{resource.id}"
      resource.present_users.add(current_user.id)
    else
      reject
    end
  end

  def unsubscribed
    resource = GlobalID::Locator.locate_signed params[:signed_resource]
    return unless resource.present?

    resource.present_users.remove(current_user.id)
  end
end
