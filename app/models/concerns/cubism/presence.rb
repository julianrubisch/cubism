module Cubism::Presence
  extend ActiveSupport::Concern

  included do
    kredis_set :present_users, after_change: :stream_presence
    kredis_set :cubicle_element_ids
    kredis_hash :excluded_user_id_for_element_id
  end

  def stream_presence
    Cubism::Broadcaster.new(resource: self).broadcast
  end
end
