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

  BlockStoreItem = Struct.new(:context, :block, keyword_init: true)
end
