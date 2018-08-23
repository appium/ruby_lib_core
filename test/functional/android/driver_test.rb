require 'test_helper'

# $ rake test:func:android TEST=test/functional/android/driver_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  class DriverTest < AppiumLibCoreTest::Function::TestCase
    def setup
      @@core ||= ::Appium::Core.for(self, Caps.android)
      @driver = @@core.start_driver
    end

    def teardown
      save_reports(@driver)
    end

    def test_appium_server_version
      v = @@core.appium_server_version

      refute_nil v['build']['version']
    end

    def test_platform_version
      # @@core.platform_version #=> [7, 1, 1]
      assert @@core.platform_version.length > 1
    end

    def test_screenshot
      file = @@core.screenshot './android_test.png'

      assert File.exist?(file.path)

      File.delete file.path
      assert !File.exist?(file.path)
    end

    def test_wait_true
      e = @@core.wait_true { @driver.find_element :accessibility_id, 'Content' }
      assert e.text
    end

    def test_wait
      e = @@core.wait { @driver.find_element :accessibility_id, 'Content' }
      assert_equal 'Content', e.text
    end

    # TODO: call @driver.quit after tests
  end
end
