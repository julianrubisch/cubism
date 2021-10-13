module Cubism::User
  extend ActiveSupport::Concern

  included do
    Cubism.user_class = self

    class_eval do
      cattr_accessor :cubicle_attributes
    end
  end
end
