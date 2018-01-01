require 'test_helper'

# $ rake test:func:android TEST=test/functional/android/webdriver/create_session_test.rb
class AppiumLibCoreTest
  module WebDriver
    class CreateSessionTestTest < AppiumLibCoreTest::Function::TestCase
      def test_mjsonwp
        caps = Caps::ANDROID_OPS[:caps].merge({ forceMjsonwp: true })
        new_caps = Caps::ANDROID_OPS.merge({ caps: caps })
        core = ::Appium::Core.for(self, new_caps)

        driver = core.start_driver

        assert_equal :oss, driver.dialect
        assert driver.capabilities[:forceMjsonwp].nil?
        assert driver.capabilities['forceMjsonwp'].nil?
      end

      # Require Appium 1.7.2+
      def test_w3c
        caps = Caps::ANDROID_OPS[:caps].merge({ forceMjsonwp: false })
        new_caps = Caps::ANDROID_OPS.merge({ caps: caps })
        core = ::Appium::Core.for(self, new_caps)

        driver = core.start_driver

        assert_equal :w3c, driver.dialect
        assert driver.capabilities[:forceMjsonwp].nil?
        assert driver.capabilities['forceMjsonwp'].nil?
      end

      # Require Appium 1.7.2+
      def test_w3c_default
        caps = Caps::ANDROID_OPS
        core = ::Appium::Core.for(self, caps)

        driver = core.start_driver

        assert_equal :w3c, driver.dialect
        assert driver.capabilities[:forceMjsonwp].nil?
        assert driver.capabilities['forceMjsonwp'].nil?

        driver.quit
      end
    end
  end
end
