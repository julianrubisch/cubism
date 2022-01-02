class CubismHelperTest < ActionView::TestCase
  include CubismHelper

  setup do
    @post = posts(:one)
    @user = users(:one)
  end

  teardown do
    Cubism.store.clear
  end

  test "it displays a cubicle element for a resource" do
    element = Nokogiri::HTML.fragment(cubicle_for(@post, @user) { |users| })

    cubicle_element = element.children.first

    assert_equal "cubicle-element", cubicle_element.name
    assert_equal @user, GlobalID::Locator.locate_signed(cubicle_element["user"])
    assert_equal "connect", cubicle_element["appear-trigger"]
    assert_nil cubicle_element["disappear-trigger"]
    assert_nil cubicle_element["trigger-root"]
    assert cubicle_element["exclude-current-user"]

    refute_nil cubicle_element["id"]
  end

  test "it passes html_options" do
    element = Nokogiri::HTML.fragment(cubicle_for(@post, @user, html_options: {class: "my-class1 my-class2"}) { |users| })
    cubicle_element = element.children.first

    assert_equal "my-class1 my-class2", cubicle_element["class"]
  end

  test "it stores the passed block in the global store" do
    Nokogiri::HTML.fragment(cubicle_for(@post, @user) { |users| })

    assert_equal 1, Cubism.store.size
  end
end
