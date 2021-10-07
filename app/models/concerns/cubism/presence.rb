module Cubism::Presence
  extend ActiveSupport::Concern

  included do
    kredis_set :present_users
  end
end
