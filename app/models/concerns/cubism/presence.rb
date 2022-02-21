module Cubism::Presence
  extend ActiveSupport::Concern

  included do
    kredis_hash :present_users, after_change: :stream_presence
    kredis_set :cubicle_element_ids
    kredis_hash :excluded_user_id_for_element_id
  end

  def stream_presence
    Cubism::Broadcaster.new(resource: self).broadcast
  end

  def present_users_for_scope(scope = "")
    present_users[scope].present? ? Marshal.load(present_users[scope]) : Set.new
  end

  def set_present_users_for_scope(user_ids, scope = "")
    present_users[scope] = Marshal.dump(Set.new(user_ids))
  end

  def present_users_for_element_id(element_id)
    users = Cubism.user_class.find(present_users.members)
    users.reject! { |user| user.id == excluded_user_id_for_element_id[element_id].to_i }

    users
  end
end
