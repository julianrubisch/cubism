module Cubism
  class Preprocessor
    def initialize(source:, view_context:)
      start_pos = /<%= cubicle_for/ =~ source
      @source = source[start_pos..]
      @view_context = view_context
    end

    def process
      begin
        do_parse
      rescue NameError
        # we ignore any name errors from unset instance variables or local assigns here
      end

      @source
    end

    def do_parse
      ActionView::Template::Handlers::ERB::Erubi.new(@source).evaluate(@view_context)
    rescue SyntaxError
      @source = @source[..-2]
      do_parse
    end
  end
end
