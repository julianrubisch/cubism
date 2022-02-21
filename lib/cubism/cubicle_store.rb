module Cubism
  class CubicleStore
    delegate_missing_to :@blocks

    def initialize(key)
      @blocks = Kredis.hash key
    end

    def [](key)
      Marshal.load(@blocks[key]) if @blocks[key]
    end

    def []=(key, value)
      mutex.synchronize do
        @blocks[key] = Marshal.dump value
      end
    end

    def fetch(key, value = nil, &block)
      if self[key].nil?
        yield value if block
        self[key] = value
      end

      self[key]
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

  # Container for cubicle blocks
  BlockContainer = Struct.new(
    :block_location,
    :block_source,
    :user_gid,
    :resource_gid,
    :scope,
    keyword_init: true
  ) do
    def initialize(*args)
      super

      @filename, _lineno = block_location.split(":")
    end

    def user
      GlobalID::Locator.locate self[:user_gid]
    end

    def resource
      GlobalID::Locator.locate self[:resource_gid]
    end

    def digest
      resource_user_key = [resource_gid, user_gid, scope].join(":")

      ActiveSupport::Digest.hexdigest("#{block_location}:#{File.read(@filename)}:#{resource_user_key}")
    end

    def marshal_dump
      to_h.merge(block_source: block_source.digest)
    end

    def marshal_load(serialized_item)
      members.excluding(:block_source).each do |arg|
        send("#{arg}=", serialized_item[arg])
      end

      self.block_source = Cubism.source_store[serialized_item[:block_source]]
    end
  end

  # Container for cubicle block sources
  BlockSource = Struct.new(
    :location,
    :source,
    :variable_name,
    :view_context,
    keyword_init: true
  ) do
    def self.find_or_create(location:, view_context:)
      instance = new(location: location, view_context: view_context)

      Cubism.source_store.fetch(instance.digest, instance) do |instance|
        instance.parse!
      end

      instance
    end

    def initialize(*args)
      super

      @filename, @lineno = location.split(":")
      @lineno = @lineno.to_i
    end

    def parse!
      return if location.start_with?("inline template")

      lines = File.readlines(@filename)[@lineno - 1..]

      preprocessor = Cubism::Preprocessor.new(source: lines.join.squish, view_context: view_context)
      self.variable_name = preprocessor.block_variable_name
      self.source = preprocessor.process
    end

    def digest
      ActiveSupport::Digest.hexdigest("#{location}:#{File.read(@filename)}")
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
