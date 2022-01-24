class PreprocessorTest < ActionView::TestCase
  test "it extracts a simple cubicle_for block" do
    source = <<-ERB
      <%= cubicle_for post, user do |users| %>
        <span class="presence">
          <%= users.map(&:username).to_sentence %>
        <span>
      <% end %>
    ERB

    result = <<~ERB
      <span class="presence">
        <%= users.map(&:username).to_sentence %>
      <span>
    ERB

    preprocessor = Cubism::Preprocessor.new(source: source, view_context: self)

    assert_equal result.squish, preprocessor.process.squish
  end

  test "it respects ERB tags nested in the block" do
    source = <<-ERB
      <%= cubicle_for post, user do |users| %>
        <% if users.size > 0 %>
          <span class="presence">
            <%= users.map(&:username).to_sentence %>
          <span>
        <% end %>
      <% end %>
    ERB

    result = <<~ERB
      <% if users.size > 0 %>
        <span class="presence">
          <%= users.map(&:username).to_sentence %>
        <span>
      <% end %>
    ERB

    preprocessor = Cubism::Preprocessor.new(source: source, view_context: self)

    assert_equal result.squish, preprocessor.process.squish
  end

  test "it respects render calls nested in the block" do
    source = <<-ERB
      <%= cubicle_for post, user do |users| %>
        <%= render "presence_partial", users: users %>
      <% end %>
    ERB

    result = <<~ERB
      <%= render "presence_partial", users: users %>
    ERB

    preprocessor = Cubism::Preprocessor.new(source: source, view_context: self)

    assert_equal result.squish, preprocessor.process.squish
  end
end
