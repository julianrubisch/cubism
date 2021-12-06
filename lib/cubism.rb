require "kredis"

require "cubism/version"
require "cubism/engine"

module Cubism
  mattr_accessor :user_class, instance_writer: false, instance_reader: false
  mattr_accessor :current_user_helper, instance_writer: false, instance_reader: false

  ActiveSupport.on_load :action_controller do
    include Cubism::SetCurrent
  end
end
