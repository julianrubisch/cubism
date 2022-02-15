require "kredis"

require "cubism/version"
require "cubism/engine"
require "cubism/broadcaster"
require "cubism/cubicle_store"
require "cubism/preprocessor"

module Cubism
  extend ActiveSupport::Autoload

  autoload :Broadcaster, "cubism/broadcaster"
  autoload :Preprocessor, "cubism/preprocessor"

  mattr_accessor :user_class, instance_writer: false, instance_reader: false

  mattr_accessor :block_store, instance_reader: false
  mattr_accessor :source_store, instance_reader: false
end
