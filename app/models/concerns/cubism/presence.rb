module Cubism::Presence
  extend ActiveSupport::Concern

  included do
    kredis_set :present_users, after_change: :stream_presence_later
  end

  def stream_presence_later
    Cubism::StreamPresenceJob.perform_later(resource: self)
  end
end
