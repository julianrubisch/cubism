class Cubism::PresenceChannel < ActionCable::Channel::Base
  include CableReady::StreamIdentifier

  def subscribed
    if resource.present?
      stream_from params[:element_id]
      resource.present_users[scope] ||= Set.new
      resource.cubicle_element_ids << element_id
      resource.excluded_user_id_for_element_id[element_id] = user.id if exclude_current_user?
    else
      reject
    end
  end

  def unsubscribed
    return unless resource.present?

    resource.cubicle_element_ids.remove(element_id)
    resource.excluded_user_id_for_element_id.delete(element_id)
    disappear
  end

  def appear
    resource.present_users[scope].add(user.id)
  end

  def disappear
    resource.present_users[scope].remove(user.id)
  end

  private

  def resource
    locator = verified_stream_identifier(params[:identifier])
    GlobalID::Locator.locate(locator)
  end

  def user
    GlobalID::Locator.locate_signed(params[:user])
  end

  def exclude_current_user?
    params[:exclude_current_user]
  end

  def element_id
    params[:element_id]
  end

  def url
    params[:url]
  end

  def scope
    params[:scope] || ""
  end
end
