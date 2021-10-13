require "cubism/version"
require "cubism/engine"

module Cubism
  mattr_accessor :user_class, instance_writer: false, instance_reader: false
end
