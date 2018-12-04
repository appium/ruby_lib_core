require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'appium_lib_core'

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest'

$VERBOSE = nil
Appium::Logger.level = ::Logger::FATAL # Show Logger logs only they are fatal

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

ROOT_REPORT_PATH = "#{Dir.pwd}/test/report".freeze
START_AT = Time.now.strftime('%Y-%m-%d-%H%M%S').freeze

Dir.mkdir(ROOT_REPORT_PATH) unless Dir.exist? ROOT_REPORT_PATH
FileUtils.mkdir_p("#{ROOT_REPORT_PATH}/#{START_AT}") unless FileTest.exist? "#{ROOT_REPORT_PATH}/#{START_AT}"

class AppiumLibCoreTest
  module Function
    class TestCase < Minitest::Test
      def save_reports(driver)
        return if passed?

        # Save failed view's screenshot and source
        base_path = "#{ROOT_REPORT_PATH}/#{START_AT}/#{self.class.name.gsub('::', '_')}"
        FileUtils.mkdir_p(base_path) unless FileTest.exist? base_path

        File.write "#{base_path}/#{name}-failed.xml", driver.page_source
        driver.save_screenshot "#{base_path}/#{name}-failed.png"
      end
    end
  end
end

class AppiumLibCoreTest
  def self.required_appium_version?(core_driver, required)
    version = core_driver.appium_server_version

    return false if version.empty?

    v = version['build']['version'].split('-') # 1.9.2-beta.2 => ['1.9.2', 'beta.2']
    v[0] >= required.to_s
  end

  def self.path_of(path)
    path_dup = path.dup
    path_dup.tr!('/', '\\') if ::Appium::Core::Base.platform.windows?
    path_dup
  end

  class Caps
    def self.ios
      new.ios
    end

    def self.android(activity_name = nil)
      new.android(activity_name)
    end

    def self.android_web
      new.android_web
    end

    # Require a simulator which OS version is 11.4, for example.
    def ios
      wda_local_port = get_wda_local_port
      device_name = parallel? ? "iPhone 8 - #{wda_local_port}" : 'iPhone 8'

      {
        caps: { # :desiredCapabilities is also available
          platformName: :ios,
          automationName: 'XCUITest',
          app: 'test/functional/app/UICatalog.app.zip',
          platformVersion: '11.4',
          deviceName: device_name,
          # useNewWDA: true,
          useJSONSource: true,
          someCapability: 'some_capability',
          newCommandTimeout: 120,
          wdaLocalPort: wda_local_port,
          # `true`, which is the default value, is faster to finishing launching part in many cases
          # But sometimes `false` is necessary. It leads regressions sometimes though.
          waitForQuiescence: true,
          reduceMotion: true,
          screenshotQuality: 2 # The lowest quality screenshots
        },
        appium_lib: {
          export_session: true,
          wait: 30,
          wait_timeout: 20,
          wait_interval: 1
        }
      }
    end

    # Require a real device or an emulator.
    # We should update platformVersion and deviceName to fit your environment.
    def android(activity_name = nil)
      {
        desired_capabilities: { # :caps is also available
          platformName: :android,
          automationName: ENV['AUTOMATION_NAME'] || 'uiautomator2',
          app: 'test/functional/app/api.apk.zip',
          udid: get_udid_name,
          deviceName: 'Android Emulator',
          appPackage: 'io.appium.android.apis',
          appActivity: activity_name || 'io.appium.android.apis.ApiDemos',
          someCapability: 'some_capability',
          unicodeKeyboard: true,
          resetKeyboard: true,
          disableWindowAnimation: true,
          newCommandTimeout: 300,
          systemPort: get_system_port,
          language: 'en',
          locale: 'US',
          adbExecTimeout: 5_000, # 5 sec
          # An emulator 8.1 has Chrome/61.0.3163.98
          # Download a chrome driver from https://chromedriver.storage.googleapis.com/index.html?path=2.34/
          # chromedriverExecutable: "#{Dir.pwd}/test/functional/app/chromedriver_2.34",
          chromeOptions: {
            args: ['--disable-popup-blocking']
          }
        },
        appium_lib: {
          export_session: true,
          wait: 30,
          wait_timeout: 20,
          wait_interval: 1
        }
      }
    end

    def android_web
      {
        caps: {
          browserName: :chrome,
          platformName: :android,
          automationName: ENV['AUTOMATION_NAME'] || 'uiautomator2',
          chromeOptions: { androidPackage: 'com.android.chrome', args: ['--disable-popup-blocking'] },
          # refer: https://github.com/appium/appium/blob/master/docs/en/writing-running-appium/web/chromedriver.md
          # An emulator 8.1 has Chrome/61.0.3163.98
          # Download a chrome driver from https://chromedriver.storage.googleapis.com/index.html?path=2.34/
          # chromedriverExecutable: "#{Dir.pwd}/test/functional/app/chromedriver_2.34",
          # Or `npm install --chromedriver_version="2.24"` and
          # chromedriverUseSystemExecutable: true,
          udid: get_udid_name,
          deviceName: 'Android Emulator',
          someCapability: 'some_capability',
          unicodeKeyboard: true,
          resetKeyboard: true,
          disableWindowAnimation: true,
          newCommandTimeout: 300,
          systemPort: get_system_port,
          language: 'en',
          locale: 'US'
        },
        appium_lib: {
          export_session: true,
          wait: 30,
          wait_timeout: 20,
          wait_interval: 1
        }
      }
    end

    def parallel?
      ENV['PARALLEL']
    end

    private

    def get_wda_local_port
      # TEST_ENV_NUMBER is provided by parallel_tests gem
      # The number is '', '2', '3',...
      number = ENV['TEST_ENV_NUMBER'] || ''
      core_number = number.empty? ? 0 : number.to_i - 1
      [8100, 8101][core_number]
    end

    def get_system_port
      number = ENV['TEST_ENV_NUMBER'] || ''
      core_number = number.empty? ? 0 : number.to_i - 1
      [8200, 8201, 8202][core_number]
    end

    def get_udid_name
      number = ENV['TEST_ENV_NUMBER'] || ''
      core_number = number.empty? ? 0 : number.to_i - 1
      %w(emulator-5554 emulator-5556 emulator-5558)[core_number]
    end
  end

  module Mock
    HEADER = { 'Content-Type' => 'application/json; charset=utf-8', 'Cache-Control' => 'no-cache' }.freeze
    SESSION = 'http://127.0.0.1:4723/wd/hub/session/1234567890'.freeze

    def android_mock_create_session
      response = {
        status: 0, # To make bridge.dialect == :oss
        value: {
          sessionId: '1234567890',
          capabilities: {
            platform: 'LINUX',
            webStorageEnabled: false,
            takesScreenshot: true,
            javascriptEnabled: true,
            databaseEnabled: false,
            networkConnectionEnabled: true,
            locationContextEnabled: false,
            warnings: {},
            desired: {
              platformName: 'Android',
              automationName: 'uiautomator2',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              app: '/test/apps/ApiDemos-debug.apk',
              newCommandTimeout: 240,
              unicodeKeyboard: true,
              resetKeyboard: true
            },
            platformName: 'Android',
            automationName: 'uiautomator2',
            platformVersion: '7.1.1',
            deviceName: 'emulator-5554',
            app: '/test/apps/ApiDemos-debug.apk',
            newCommandTimeout: 240,
            unicodeKeyboard: true,
            resetKeyboard: true,
            deviceUDID: 'emulator-5554',
            deviceScreenSize: '1080x1920',
            deviceModel: 'Android SDK built for x86_64',
            deviceManufacturer: 'unknown',
            appPackage: 'com.example.android.apis',
            appWaitPackage: 'com.example.android.apis',
            appActivity: 'com.example.android.apis.ApiDemos',
            appWaitActivity: 'com.example.android.apis.ApiDemos'
          }
        }
      }.to_json

      stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
        .to_return(headers: HEADER, status: 200, body: response)

      stub_request(:post, "#{SESSION}/timeouts/implicit_wait")
        .with(body: { ms: 30_000 }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

      driver = @core.start_driver

      assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
      assert_requested(:post, "#{SESSION}/timeouts/implicit_wait", times: 1)
      driver
    end

    def android_mock_create_session_w3c
      response = {
        value: {
          sessionId: '1234567890',
          capabilities: {
            platformName: :android,
            automationName: 'uiautomator2',
            app: 'test/functional/app/api.apk.zip',
            platformVersion: '7.1.1',
            deviceName: 'Android Emulator',
            appPackage: 'io.appium.android.apis',
            appActivity: 'io.appium.android.apis.ApiDemos',
            someCapability: 'some_capability',
            unicodeKeyboard: true,
            resetKeyboard: true
          }
        }
      }.to_json

      stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
        .to_return(headers: HEADER, status: 200, body: response)

      stub_request(:post, "#{SESSION}/timeouts")
        .with(body: { implicit: 30_000 }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

      driver = @core.start_driver

      assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
      assert_requested(:post, "#{SESSION}/timeouts", body: { implicit: 30_000 }.to_json, times: 1)
      driver
    end

    def ios_mock_create_session
      response = {
        status: 0, # To make bridge.dialect == :oss
        value: {
          sessionId: '1234567890',
          capabilities: {
            device: 'iphone',
            browserName: 'UICatalog',
            sdkVersion: '11.4',
            CFBundleIdentifier: 'com.example.apple-samplecode.UICatalog'
          }
        }
      }.to_json

      stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
        .to_return(headers: HEADER, status: 200, body: response)

      stub_request(:post, "#{SESSION}/timeouts/implicit_wait")
        .with(body: { ms: 30_000 }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

      driver = @core.start_driver

      assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
      assert_requested(:post, "#{SESSION}/timeouts/implicit_wait", times: 1)
      driver
    end

    def ios_mock_create_session_w3c
      response = {
        value: {
          sessionId: '1234567890',
          capabilities: {
            device: 'iphone',
            browserName: 'UICatalog',
            sdkVersion: '11.4',
            CFBundleIdentifier: 'com.example.apple-samplecode.UICatalog'
          }
        }
      }.to_json

      stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
        .to_return(headers: HEADER, status: 200, body: response)

      stub_request(:post, "#{SESSION}/timeouts")
        .with(body: { implicit: 30_000 }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

      driver = @core.start_driver

      assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
      assert_requested(:post, "#{SESSION}/timeouts", body: { implicit: 30_000 }.to_json, times: 1)
      driver
    end
  end
end
