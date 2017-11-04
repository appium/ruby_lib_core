require 'test_helper'

class AppiumLibCoreTest < Minitest::Test
  def test_version
    ::Appium::Core::VERSION.wont_be_nil
  end
end
