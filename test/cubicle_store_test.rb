require "test_helper"

class CubicleStoreTest < ActiveSupport::TestCase
  setup do
    @store = Cubism::CubicleStore.new("cubism-test")
  end

  test "empty value just retrieves the key" do
    @store["foo"] = "bar"

    value = @store.fetch("foo")

    refute_nil @store["foo"]
    assert_equal "bar", value
  end

  test "fetch assigns value to empty key" do
    assert_nil @store["foo"]

    value = @store.fetch("foo", "bar")

    refute_nil @store["foo"]
    assert_equal "bar", value
  end

  test "fetch retrieves value for existing key, and does not overwrite it" do
    @store["foo"] = "baz"

    value = @store.fetch("foo", "bar")

    refute_nil @store["foo"]
    assert_equal "baz", value
  end
end
