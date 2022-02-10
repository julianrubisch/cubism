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

  BlockStoreItem = Struct.new(
    :block_location,
    :block_source,
    :block_variable_name,
    :user_gid,
    :resource_gid,
    :view_context,
    keyword_init: true
  ) do
    def initialize(*args)
      super

      @filename, @lineno = block_location.split(":")
      @lineno = @lineno.to_i
    end

    def user
      GlobalID::Locator.locate self[:user_gid]
    end

    def resource
      GlobalID::Locator.locate self[:resource_gid]
    end

    def parse!
      return if block_location.start_with?("inline template")

      lines = File.readlines(@filename)[@lineno - 1..]

      preprocessor = Cubism::Preprocessor.new(source: lines.join.squish, view_context: view_context)
      self.block_variable_name = preprocessor.block_variable_name
      self.block_source = preprocessor.process
    end

    def digest
      resource_user_key = [resource_gid, user_gid].join(":")

      ActiveSupport::Digest.hexdigest("#{block_location}:#{File.read(@filename)}:#{resource_user_key}")
    end

    def marshal_dump
      to_h.except(:view_context)
    end

    def marshal_load(serialized_item)
      members.excluding(:view_context).each do |arg|
        send("#{arg}=", serialized_item[arg])
      end
    end
  end
end
