require 'test_helper'

# $ rake test:func:ios TEST=test/functional/ios/driver_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  class DriverTest < AppiumLibCoreTest::Function::TestCase
    def setup
      @@core ||= ::Appium::Core.for(Caps.ios)
      @@driver ||= @@core.start_driver
    end

    def teardown
      save_reports(@@driver)
    end

    def test_appium_server_version
      v = @@core.appium_server_version

      refute_nil v['build']['version']
      refute_nil v['build']['revision']
    end

    def test_platform_version
      assert_equal [10, 3], @@core.platform_version
    end

    def test_screenshot
      file = @@core.screenshot './ios_test.png'

      assert File.exist?(file.path)

      File.delete file.path
      assert !File.exist?(file.path)
    end

    def test_wait_true
      e = @@core.wait_true { @@driver.find_element :accessibility_id, 'UICatalog' }
      assert e.name
    end

    def test_wait
      e = @@core.wait { @@driver.find_element :accessibility_id, 'UICatalog' }
      assert_equal 'UICatalog', e.name
    end

    def test_click_back
      e = @@driver.find_element :accessibility_id, 'Alerts'
      e.click
      error = assert_raises ::Selenium::WebDriver::Error::StaleElementReferenceError do
        e.click
      end
      assert error.message 'does not exist'
      @@driver.back
    end

    # TODO: call @driver.quit after tests
  end
end
# rubocop:enable Style/ClassVars
