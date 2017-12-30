require 'test_helper'

# $ rake test:func:ios TEST=test/functional/ios/webdriver/create_session_test.rb
class AppiumLibCoreTest
  module WebDriver
    class CreateSessionTestTest < AppiumLibCoreTest::Function::TestCase
      def test_mjsonwp
        caps = Caps::IOS_OPS
        caps[:caps][:force_mjsonwp] = true
        core = ::Appium::Core.for(self, caps)

        driver = core.start_driver

        assert_equal :oss, driver.dialect
      end

      # Require Appium 1.7.2+
      def test_w3c
        caps = Caps::IOS_OPS
        caps[:caps][:force_mjsonwp] = false
        core = ::Appium::Core.for(self, caps)

        driver = core.start_driver

        assert_equal :w3c, driver.dialect
      end
    end
  end
end
