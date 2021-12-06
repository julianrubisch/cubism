module Cubism
  module SetCurrent
    extend ActiveSupport::Concern

    included do
      before_action do
        Cubism::Current.user = send(Cubism.current_user_helper)
      end
    end
  end
end
