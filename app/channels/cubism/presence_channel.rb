class Cubism::PresenceChannel < ActionCable::Channel::Base
  include CableReady::StreamIdentifier

  def subscribed
    return if Cubism.skip_in_test? && Rails.env.test?

    if resource.present?
      stream_from element_id
      resource.cubicle_element_ids << element_id
      resource.excluded_user_id_for_element_id[element_id] = user.id if exclude_current_user?
    else
      reject
    end
  end

  def unsubscribed
    return if Cubism.skip_in_test? && Rails.env.test?

    return unless resource.present?

    resource.cubicle_element_ids.remove(element_id)
    resource.excluded_user_id_for_element_id.delete(element_id)
    disappear
  end

  def appear
    resource.set_present_users_for_scope(resource.present_users_for_scope(scope).add(user.id), scope) if scope
  rescue ActiveRecord::RecordNotFound
    # do nothing if the user wasn't found
  end

  def disappear
    resource.set_present_users_for_scope(resource.present_users_for_scope(scope).delete(user.id), scope) if scope
  rescue ActiveRecord::RecordNotFound
    # do nothing if the user wasn't found
  end

  private

  def resource
    locator = verified_stream_identifier(params[:identifier])
    GlobalID::Locator.locate(locator)
  end

  def user
    block_container&.user
  end

  def scope
    block_container&.scope
  end

  def block_container
    Cubism.block_store[element_id]
  end

  def exclude_current_user?
    params[:exclude_current_user]
  end

  def element_id
    /cubicle-(?<element_id>.+)/ =~ params[:element_id]
    element_id
  end

  def url
    params[:url]
  end
end
