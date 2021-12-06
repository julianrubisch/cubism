module Cubism::User
  extend ActiveSupport::Concern

  included do
    Cubism.user_class = self
    Cubism.current_user_helper ||= "current_#{self.name.underscore}".to_sym

    class_eval do
      cattr_accessor :cubicle_attributes
    end
  end
end
