module Cubism
  class CubicleBlockStore
    delegate_missing_to :@blocks

    def initialize
      @blocks = Kredis.hash "cubism-blocks"
    end

    def [](key)
      Marshal.load(@blocks[key]) if @blocks[key]
    end

    def []=(key, value)
      mutex.synchronize do
        @blocks[key] = Marshal.dump value
      end
    end

    def clear
      mutex.synchronize do
        # kredis #remove
        @blocks.remove
      end
    end

    def size
      @blocks.to_h.size
    end

    private

    def mutex
      @mutex ||= Mutex.new
    end
  end

  BlockStoreItem = Struct.new(:block_location, :block_source, :user_gid, :resource_gid, keyword_init: true) do
    def user
      GlobalID::Locator.locate self[:user_gid]
    end

    def resource
      GlobalID::Locator.locate self[:resource_gid]
    end

    def marshal_dump
      to_h
    end

    def marshal_load(serialized_item)
      %i[block_location block_source user_gid resource_gid].each do |arg|
        send("#{arg}=", serialized_item[arg])
      end
    end
  end
end
