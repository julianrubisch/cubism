module Cubism::Presence
  extend ActiveSupport::Concern

  included do
    kredis_set :present_users, after_change: :stream_presence_later
    kredis_set :cubicle_element_ids
    kredis_hash :exclude_current_user_for_element_id
  end

  def stream_presence_later
    Cubism::StreamPresenceJob.perform_later(resource: self)
  end
end
