require "kredis"

require "cubism/version"
require "cubism/engine"
require "cubism/cubicle_block_store"

module Cubism
  mattr_accessor :user_class, instance_writer: false, instance_reader: false

  mattr_reader :store, instance_reader: false, default: Cubism::CubicleBlockStore.instance
end
