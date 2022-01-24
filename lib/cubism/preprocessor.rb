module Cubism
  class Preprocessor
    def initialize(source:, view_context:)
      match_data = /<%=\s+cubicle_for.+\|.+\|\s+%>/.match(source)
      start_pos = match_data&.end(0) || 0
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

    private

    def do_parse
      ActionView::Template::Handlers::ERB::Erubi.new(@source).evaluate(@view_context)
    rescue SyntaxError
      end_at_end = /(<%\s+end\s+%\>)\z/.match(@source)
      @source = end_at_end ? @source[..-(end_at_end[0].length + 1)] : @source[..-2]
      do_parse
    end
  end
end
