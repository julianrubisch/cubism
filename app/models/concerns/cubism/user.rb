module Cubism::User
  extend ActiveSupport::Concern

  included do
    Cubism.user_class = self
  end
end
