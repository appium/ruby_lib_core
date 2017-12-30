require 'test_helper'

# $ rake test:func:android TEST=test/functional/android/webdriver/create_session_test.rb
class AppiumLibCoreTest
  module WebDriver
    class CreateSessionTestTest < AppiumLibCoreTest::Function::TestCase
      def test_MJSONWP
        caps = Caps::ANDROID_OPS
        caps[:caps][:w3c] = false
        core = ::Appium::Core.for(self, caps)

        driver = core.start_driver

        assert_equal :oss, driver.dialect
      end

      # Require Appium 1.7.2+
      def test_W3C
        caps = Caps::ANDROID_OPS
        caps[:caps][:w3c] = true
        core = ::Appium::Core.for(self, caps)

        driver = core.start_driver

        assert_equal :w3c, driver.dialect
      end
    end
  end
end
