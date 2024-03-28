module Cubism
  class Preprocessor
    attr_reader :block_variable_name

    def initialize(source:, view_context:)
      match_data = /<%=\s+cubicle_for.+?\|(\w+)\|\s+%>/.match(source)
      start_pos = match_data&.end(0) || 0
      @block_variable_name = match_data[1] if match_data
      @source = source[start_pos..]
      @view_context = view_context
    end

    def process
      begin
        do_parse
      rescue NameError
        # TODO we need a better way to handle this, leads to false negatives
        # we ignore any name errors from unset instance variables or local assigns here
      end

      @source
    end

    private

    def do_parse
      erubi = ActionView::Template::Handlers::ERB::Erubi.new(@source)

      evaluate_view(erubi, @view_context)
    rescue SyntaxError
      end_at_end = /(<%\s+end\s+%>)\z/.match(@source)
      @source = end_at_end ? @source[..-(end_at_end[0].length + 1)] : @source[..-2]
      do_parse
    end

    def evaluate_view(erubi, view_context)
      view = Class.new(ActionView::Base) {
        include view_context._routes.url_helpers
        class_eval("define_method(:_template) { |local_assigns, output_buffer| #{erubi.src} }", erubi.filename.nil? ? "(erubi)" : erubi.filename, 0)
      }.empty
      view._run(:_template, nil, {}, ActionView::OutputBuffer.new)
    end
  end
end
