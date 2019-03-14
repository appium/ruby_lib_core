# frozen_string_literal: true

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'appium_lib_core'

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest'

Appium::Logger.level = ::Logger::FATAL # Show Logger logs only they are error

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

ROOT_REPORT_PATH = "#{Dir.pwd}/test/report"
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

    Gem::Version.new(version['build']['version']) >= Gem::Version.new(required.to_s)
  end

  def self.path_of(path)
    path_dup = path.dup
    path_dup = path_dup.tr('/', '\\') if ::Appium::Core::Base.platform.windows?
    path_dup
  end

  class Caps
    def self.ios
      new.ios
    end

    def self.android(activity_name = nil)
      new.android(activity_name)
    end

    def self.android_direct
      new.android_direct
    end

    def self.android_web
      new.android_web
    end

    # Require a simulator which OS version is 11.4, for example.
    def ios
      platform_version = '12.1'
      wda_local_port = _wda_local_port
      device_name = parallel? ? "iPhone 8 - #{wda_local_port}" : 'iPhone 8'

      real_device = ENV['REAL'] ? true : false

      derived_data_path = File.expand_path('tmp')
      File.mkdir(derived_data_path) unless File.exist? derived_data_path

      # for use_xctestrun_file
      build_product = File.expand_path('tmp/Build/Products/')
      xctestrun_path = real_device ?
                         "#{build_product}/WebDriverAgentRunner_iphoneos#{platform_version}-arm64.xctestrun" :
                         "#{build_product}/WebDriverAgentRunner_iphonesimulator#{platform_version}-x86_64.xctestrun"
      use_xctestrun_file = File.exist?(xctestrun_path) ? true : false

      # For real devices
      update_wda_bundleid = ENV['WDA_BUNDLEID'] || 'com.facebook.WebDriverAgentRunner'
      xcode_signing_id = 'iPhone Developer'
      xcode_org_id = ENV['ORG_ID'] || 'xxxxxxx'

      cap = {
        caps: { # :desiredCapabilities is also available
          platformName: :ios,
          automationName: ENV['AUTOMATION_NAME_IOS'] || 'XCUITest',
          app: 'test/functional/app/UICatalog.app.zip',
          udid: 'auto',
          platformVersion: platform_version,
          derivedDataPath: derived_data_path,
          deviceName: device_name,
          useNewWDA: true,
          useJSONSource: true,
          someCapability: 'some_capability',
          newCommandTimeout: 120,
          wdaLocalPort: 9000,
          # `true`, which is the default value, is faster to finishing launching part in many cases
          # But sometimes `false` is necessary. It leads regressions sometimes though.
          waitForQuiescence: true,
          reduceMotion: true,
          screenshotQuality: 2 # The lowest quality screenshots
        },
        appium_lib: {
          export_session: true,
          wait_timeout: 20,
          wait_interval: 1
        }
      }

      if use_xctestrun_file
        cap[:caps][:bootstrapPath] = build_product
        cap[:caps][:useXctestrunFile] = use_xctestrun_file
      end

      if real_device
        cap[:caps][:xcodeSigningId] = xcode_signing_id
        cap[:caps][:xcodeOrgId] = xcode_org_id
        cap[:caps][:updatedWDABundleId] = update_wda_bundleid
      end

      cap
    end

    # Require a real device or an emulator.
    # We should update platformVersion and deviceName to fit your environment.
    def android(activity_name = nil)
      {
        desired_capabilities: { # :caps is also available
          platformName: :android,
          automationName: ENV['AUTOMATION_NAME_DROID'] || 'uiautomator2',
          app: 'test/functional/app/api.apk.zip',
          udid: _udid_name,
          deviceName: 'Android Emulator',
          appPackage: 'io.appium.android.apis',
          appActivity: activity_name || 'io.appium.android.apis.ApiDemos',
          someCapability: 'some_capability',
          unicodeKeyboard: true,
          resetKeyboard: true,
          disableWindowAnimation: true,
          newCommandTimeout: 300,
          autoGrantPermissions: true,
          systemPort: _system_port,
          language: 'en',
          locale: 'US',
          adbExecTimeout: 10_000, # 10 sec
          # An emulator 8.1 has Chrome/61.0.3163.98
          # Download a chrome driver from https://chromedriver.storage.googleapis.com/index.html?path=2.34/
          # chromedriverExecutable: "#{Dir.pwd}/test/functional/app/chromedriver_2.34",
          chromeOptions: {
            args: ['--disable-popup-blocking']
          },
          uiautomator2ServerLaunchTimeout: 60_000 # ms
        },
        appium_lib: {
          export_session: true,
          wait: 0,
          wait_timeout: 20,
          wait_interval: 1
        }
      }
    end

    def android_direct
      {
        desired_capabilities: android[:desired_capabilities],
        appium_lib: {
          export_session: true,
          wait: 30,
          wait_timeout: 20,
          wait_interval: 1,
          direct_connect: true
        }
      }
    end

    def android_web
      {
        caps: {
          browserName: :chrome,
          platformName: :android,
          automationName: ENV['AUTOMATION_NAME_DROID'] || 'uiautomator2',
          chromeOptions: { androidPackage: 'com.android.chrome', args: ['--disable-popup-blocking'] },
          # refer: https://github.com/appium/appium/blob/master/docs/en/writing-running-appium/web/chromedriver.md
          # An emulator 8.1 has Chrome/61.0.3163.98
          # Download a chrome driver from https://chromedriver.storage.googleapis.com/index.html?path=2.34/
          # chromedriverExecutable: "#{Dir.pwd}/test/functional/app/chromedriver_2.34",
          # Or `npm install --chromedriver_version="2.24"` and
          # chromedriverUseSystemExecutable: true,
          udid: _udid_name,
          deviceName: 'Android Emulator',
          someCapability: 'some_capability',
          unicodeKeyboard: true,
          resetKeyboard: true,
          disableWindowAnimation: true,
          newCommandTimeout: 300,
          systemPort: _system_port,
          language: 'en',
          locale: 'US'
        },
        appium_lib: {
          export_session: true,
          wait_timeout: 20,
          wait_interval: 1
        }
      }
    end

    def parallel?
      ENV['PARALLEL']
    end

    private

    def _wda_local_port
      # TEST_ENV_NUMBER is provided by parallel_tests gem
      # The number is '', '2', '3',...
      number = ENV['TEST_ENV_NUMBER'] || ''
      core_number = number.empty? ? 0 : number.to_i - 1
      [8100, 8101][core_number]
    end

    def _system_port
      number = ENV['TEST_ENV_NUMBER'] || ''
      core_number = number.empty? ? 0 : number.to_i - 1
      [8200, 8201, 8202][core_number]
    end

    def _udid_name
      number = ENV['TEST_ENV_NUMBER'] || ''
      core_number = number.empty? ? 0 : number.to_i - 1
      %w(emulator-5554 emulator-5556 emulator-5558)[core_number]
    end
  end

  module Mock
    HEADER = { 'Content-Type' => 'application/json; charset=utf-8', 'Cache-Control' => 'no-cache' }.freeze
    SESSION = 'http://127.0.0.1:4723/wd/hub/session/1234567890'

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
              automationName: ENV['AUTOMATION_NAME_DROID'] || 'uiautomator2',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              app: '/test/apps/ApiDemos-debug.apk',
              newCommandTimeout: 240,
              unicodeKeyboard: true,
              resetKeyboard: true
            },
            platformName: 'Android',
            automationName: ENV['AUTOMATION_NAME_DROID'] || 'uiautomator2',
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
        .with(body: { ms: 0 }.to_json)
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
            automationName: ENV['AUTOMATION_NAME_DROID'] || 'uiautomator2',
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
        .with(body: { implicit: 0 }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

      driver = @core.start_driver

      assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
      assert_requested(:post, "#{SESSION}/timeouts", body: { implicit: 0 }.to_json, times: 1)
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
        .with(body: { ms: 0 }.to_json)
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
        .with(body: { implicit: 0 }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

      driver = @core.start_driver

      assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
      assert_requested(:post, "#{SESSION}/timeouts", body: { implicit: 0 }.to_json, times: 1)
      driver
    end
  end
end
