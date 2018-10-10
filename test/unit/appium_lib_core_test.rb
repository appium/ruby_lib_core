require 'test_helper'

class AppiumLibCoreTest
  class RootTest < Minitest::Test
    def test_version
      assert ::Appium::Core::VERSION != nil
    end

    def test_symbolize_keys
      result = ::Appium.symbolize_keys({'a' => 1, b: 2})
      assert_equal({a: 1, b: 2}, result)
    end

    def test_symbolize_keys_nested
      result = ::Appium.symbolize_keys({'a' => 1, b: { 'c' => 2, d: 3 }})
      assert_equal({a: 1, b: { c: 2, d: 3 }}, result)
    end
  end
end
