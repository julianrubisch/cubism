module Cubism
  class CubicleBlockStore
    include Singleton

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

    private

    def mutex
      @mutex ||= Mutex.new
    end
  end
end
