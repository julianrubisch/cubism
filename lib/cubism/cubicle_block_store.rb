module Cubism
  class CubicleBlockStore
    include Singleton

    delegate_missing_to :@blocks

    def initialize
      @blocks = {}
    end

    def [](key)
      @blocks[key]
    end

    def []=(key, value)
      mutex.synchronize do
        @blocks[key] = value
      end
    end

    def clear
      mutex.synchronize do
        @blocks.clear
      end
    end

    private

    def mutex
      @mutex ||= Mutex.new
    end
  end

  BlockStoreItem = Struct.new(:block_location, :user_gid, :resource_gid, keyword_init: true) do
    def user
      GlobalID::Locator.locate self[:user_gid]
    end

    def resource
      GlobalID::Locator.locate self[:resource_gid]
    end
  end
end
