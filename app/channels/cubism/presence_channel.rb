class Cubism::PresenceChannel < ActionCable::Channel::Base
  include CableReady::StreamIdentifier

  def subscribed
    if resource.present?
      stream_for resource
      resource.present_users.add(current_user.id)
    else
      reject
    end
  end

  def unsubscribed
    return unless resource.present?

    resource.present_users.remove(current_user.id)
  end

  private

  def resource
    locator = verified_stream_identifier(params[:identifier])
    GlobalID::Locator.locate(locator)
  end
end
