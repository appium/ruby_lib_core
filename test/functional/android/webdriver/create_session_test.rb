require 'test_helper'

# $ rake test:func:android TEST=test/functional/android/webdriver/create_session_test.rb
class AppiumLibCoreTest
  module WebDriver
    class CreateSessionTestTest < AppiumLibCoreTest::Function::TestCase
      def test_mjsonwp
        caps = Caps.android[:desired_capabilities].merge({ forceMjsonwp: true })
        new_caps = Caps.android.merge({ caps: caps })
        core = ::Appium::Core.for(new_caps)

        driver = core.start_driver

        assert_equal :oss, driver.dialect
        assert driver.capabilities[:forceMjsonwp].nil?
        assert driver.capabilities['forceMjsonwp'].nil?

        core.quit_driver
      end

      # Require Appium 1.7.2+
      def test_w3c
        caps = Caps.android[:desired_capabilities].merge({ forceMjsonwp: false })
        new_caps = Caps.android.merge({ caps: caps })
        core = ::Appium::Core.for(new_caps)

        driver = core.start_driver

        assert_equal :w3c, driver.dialect
        assert driver.capabilities[:forceMjsonwp].nil?
        assert driver.capabilities['forceMjsonwp'].nil?

        driver.quit # We can quit driver in this way as well
      end

      # Require Appium 1.7.2+
      def test_w3c_default
        caps = Caps.android
        core = ::Appium::Core.for(caps)

        driver = core.start_driver

        assert_equal :w3c, driver.dialect
        assert driver.capabilities[:forceMjsonwp].nil?
        assert driver.capabilities['forceMjsonwp'].nil?

        core.quit_driver
      end
    end
  end
end
