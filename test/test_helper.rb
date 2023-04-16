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

begin
  Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new]
rescue Errno::ENOENT
  # Ignore since Minitest::Reporters::JUnitReporter.new fails in deleting files, sometimes
end

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

      # Calls 'skip' if the appium version is not satisfied the version
      def skip_as_appium_version(required_version)
        return if ENV['IGNORE_VERSION_SKIP'].nil? || ENV['IGNORE_VERSION_SKIP'] == 'true'
        return if AppiumLibCoreTest.appium_version == 'beta'
        return if AppiumLibCoreTest.appium_version == 'next'

        # rubocop:disable Style/GuardClause
        if Gem::Version.new(AppiumLibCoreTest.appium_version) < Gem::Version.new(required_version.to_s)
          skip "Appium #{required_version} is required"
        end
        # rubocop:enable Style/GuardClause
      end

      def newer_appium_than_or_beta?(version)
        return true if AppiumLibCoreTest.appium_version == 'beta'
        return true if AppiumLibCoreTest.appium_version == 'next'

        Gem::Version.new(AppiumLibCoreTest.appium_version) > Gem::Version.new(version.to_s)
      end

      def over_ios13?(driver)
        Gem::Version.create(driver.capabilities['platformVersion']) >= Gem::Version.create('13.0')
      end

      def over_ios14?(driver)
        Gem::Version.create(driver.capabilities['platformVersion']) >= Gem::Version.create('14.0')
      end

      def ci?
        ENV['CI'] == 'true'
      end
    end
  end
end

class AppiumLibCoreTest
  def self.path_of(path)
    path_dup = path.dup
    path_dup = path_dup.tr('/', '\\') if ::Appium::Core::Base.platform.windows?
    path_dup
  end

  def self.appium_version
    ENV['APPIUM_VERSION'] || 'beta'
  end

  class Caps
    def self.ios(platform_name = :ios)
      new.ios(platform_name)
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

    def self.windows
      new.windows
    end

    def self.mac2
      new.mac2
    end

    # Require a simulator which OS version is 11.4, for example.
    def ios(platform_name = :ios)
      platform_version = '16.2'
      wda_port = wda_local_port

      real_device = ENV['REAL'] ? true : false

      cap = {
        caps: { # :desiredCapabilities is also available
          platformName: platform_name,
          automationName: ENV['APPIUM_DRIVER'] || 'XCUITest',
          # udid: 'auto',
          platformVersion: platform_version,
          deviceName: device_name(platform_version, platform_name, wda_port),
          useNewWDA: false,
          eventTimings: true,
          useJSONSource: true,
          someCapability: 'some_capability',
          wdaLaunchTimeout: 120_000,
          newCommandTimeout: 120,
          wdaLocalPort: wda_port,
          # `true`, which is the default value, is faster to finishing launching part in many cases
          # But sometimes `false` is necessary. It leads regressions sometimes though.
          waitForQuiescence: true,
          reduceMotion: true,
          orientation: 'PORTRAIT', # only for simulator
          processArguments: { args: %w(happy tseting), env: { HAPPY: 'testing' } },
          screenshotQuality: 2, # The lowest quality screenshots
          connectHardwareKeyboard: false,
          maxTypingFrequency: 200
        },
        appium_lib: {
          export_session: true,
          wait_timeout: 20,
          wait_interval: 1
        }
      }

      if ENV['BUNDLE_ID'].nil?
        cap[:caps][:app] = if cap[:caps][:platformName].downcase == :tvos
                             # Use https://github.com/KazuCocoa/tv-example as a temporary
                             "#{Dir.pwd}/test/functional/app/tv-example.zip"
                           else
                             test_app platform_version
                           end
      else
        cap[:caps][:bundleId] = ENV['BUNDLE_ID'] || 'io.appium.apple-samplecode.UICatalog'
      end

      unless ENV['UNIT_TEST']
        xcode_org_id = ENV['ORG_ID'] || 'Simulator'
        cap = add_ios_real_device(cap.dup, xcode_org_id) if real_device
        cap = add_xctestrun(real_device, cap.dup, xcode_org_id)
      end

      cap
    end

    private

    def over_ios13?(os_version)
      Gem::Version.create(os_version) >= Gem::Version.create('13.0')
    end

    def over_ios14?(os_version)
      Gem::Version.create(os_version) >= Gem::Version.create('14.0')
    end

    def test_app(os_version)
      if over_ios13?(os_version)
        # https://github.com/appium/ios-uicatalog/pull/15
        "#{Dir.pwd}/test/functional/app/iOS13__UICatalog.app.zip"
      else
        "#{Dir.pwd}/test/functional/app/UICatalog.app.zip"
      end
    end

    def device_name(os_version, platform_name, wda_local_port)
      if platform_name.downcase == :tvos
        'Apple TV'
      else
        name = if over_ios13?(os_version)
                 'iPhone 11'
               else
                 'iPhone Xs Max'
               end

        parallel? ? "#{name} - #{wda_local_port}" : name
      end
    end

    # for use_xctestrun_file
    def add_xctestrun(real_device, caps, xcode_org_id)
      xcode_sdk_version = /iPhoneOS([0-9.]+)\.sdk/.match(`xcodebuild -version -sdk`)[1]

      derived_data_path = File.expand_path("tmp/#{xcode_org_id}") # Can run in parallel if we set here as a unique path
      FileUtils.mkdir_p(derived_data_path) unless File.exist? derived_data_path
      caps[:caps][:derivedDataPath] = derived_data_path

      platform_name = caps[:caps][:platformName].downcase
      runnner_prefix = platform_name == :tvos ? 'WebDriverAgentRunner_tvOS_appletv' : 'WebDriverAgentRunner_iphone'

      build_product = File.expand_path("#{derived_data_path}/Build/Products/")
      xctestrun_path = if real_device
                         "#{build_product}/#{runnner_prefix}os#{xcode_sdk_version}-arm64.xctestrun"
                       else
                         "#{build_product}/#{runnner_prefix}simulator#{xcode_sdk_version}-x86_64.xctestrun"
                       end
      use_xctestrun_file = File.exist? xctestrun_path

      if use_xctestrun_file
        caps[:caps][:bootstrapPath] = build_product
        caps[:caps][:useXctestrunFile] = use_xctestrun_file
      end

      caps
    end

    # For real devices
    def add_ios_real_device(caps, xcode_org_id)
      if ENV['XCODE_CONFIG_FILE']
        caps[:caps][:xcodeConfigFile] = ENV['XCODE_CONFIG_FILE']
        return caps
      end

      update_wda_bundleid = ENV['WDA_BUNDLEID'] || 'com.facebook.WebDriverAgentRunner'
      xcode_signing_id = 'iPhone Developer'

      # Can use 'xcodeConfigFile' also if we set the cap properly
      caps[:caps][:xcodeSigningId] = xcode_signing_id
      caps[:caps][:xcodeOrgId] = xcode_org_id
      caps[:caps][:updatedWDABundleId] = update_wda_bundleid

      caps
    end

    public

    # Require a real device or an emulator.
    # We should update platformVersion and deviceName to fit your environment.
    def android(activity_name = nil)
      cap = {
        capabilities: { # :caps is also available
          platformName: :android,
          automationName: ENV['APPIUM_DRIVER'] || 'uiautomator2',
          app: 'test/functional/app/api.apk.zip',
          udid: udid_name,
          deviceName: 'Android Emulator',
          appPackage: 'io.appium.android.apis',
          appActivity: activity_name || 'io.appium.android.apis.ApiDemos',
          someCapability: 'some_capability',
          eventTimings: true,
          disableWindowAnimation: true,
          newCommandTimeout: 300,
          autoGrantPermissions: true,
          systemPort: system_port,
          language: 'en',
          locale: 'US',
          # An emulator 8.1 has Chrome/61.0.3163.98
          # Download a chrome driver from https://chromedriver.storage.googleapis.com/index.html?path=2.34/
          # chromedriverExecutable: "#{Dir.pwd}/test/functional/app/chromedriver_2.34",
          chromeOptions: {
            args: ['--disable-popup-blocking']
          },
          adbExecTimeout: 60_000, # ms
          uiautomator2ServerLaunchTimeout: 60_000 # ms
        },
        appium_lib: {
          export_session: true,
          wait: 5,
          wait_timeout: 20,
          wait_interval: 1
        }
      }

      # settins in caps should work over Appium 1.13.0
      if cap[:capabilities][:automationName] == 'uiautomator2' && (
        AppiumLibCoreTest.appium_version == 'beta' || AppiumLibCoreTest.appium_version == 'next'
      )
        cap[:capabilities]['settings[trackScrollEvents]'] = false
      else
        cap[:capabilities][:forceEspressoRebuild] = false
        cap[:capabilities][:espressoBuildConfig] = {}.to_json
      end

      cap
    end

    def android_direct
      {
        capabilities: android[:capabilities],
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
          automationName: ENV['APPIUM_DRIVER'] || 'uiautomator2',
          chromeOptions: { androidPackage: 'com.android.chrome', args: %w(--disable-fre --disable-popup-blocking) },
          # refer: https://github.com/appium/appium/blob/1.x/docs/en/writing-running-appium/web/chromedriver.md
          # An emulator 8.1 has Chrome/61.0.3163.98
          # Download a chrome driver from https://chromedriver.storage.googleapis.com/index.html?path=2.34/
          # chromedriverExecutable: "#{Dir.pwd}/test/functional/app/chromedriver_2.34",
          # Or `npm install --chromedriver_version="2.24"` and
          # chromedriverUseSystemExecutable: true,
          udid: udid_name,
          deviceName: 'Android Emulator',
          someCapability: 'some_capability',
          disableWindowAnimation: true,
          newCommandTimeout: 300,
          systemPort: system_port,
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

    def windows
      {
        caps: {
          platformName: :windows,
          automationName: :windows,
          deviceName: 'WindowsPC',
          app: 'Microsoft.WindowsCalculator_8wekyb3d8bbwe!App'
        },
        appium_lib: {
          export_session: true,
          wait_timeout: 20,
          wait_interval: 1
        }
      }
    end

    def mac2
      {
        caps: {
          platformName: :mac,
          automationName: :mac2
        }
      }
    end

    def parallel?
      ENV.fetch 'PARALLEL', false
    end

    private

    def wda_local_port
      # TEST_ENV_NUMBER is provided by parallel_tests gem
      # The number is '', '2', '3',...
      number = ENV['TEST_ENV_NUMBER'] || ''
      core_number = number.empty? ? 0 : number.to_i - 1
      [8100, 8101][core_number]
    end

    def system_port
      number = ENV['TEST_ENV_NUMBER'] || ''
      core_number = number.empty? ? 0 : number.to_i - 1
      [8200, 8201, 8202][core_number]
    end

    def udid_name
      number = ENV['TEST_ENV_NUMBER'] || ''
      core_number = number.empty? ? 0 : number.to_i - 1
      %w(emulator-5554 emulator-5556 emulator-5558)[core_number]
    end
  end

  module Mock
    HEADER = { 'Content-Type' => 'application/json; charset=utf-8', 'Cache-Control' => 'no-cache' }.freeze
    NOSESSION = 'http://127.0.0.1:4723/wd/hub'
    SESSION = 'http://127.0.0.1:4723/wd/hub/session/1234567890'

    def android_mock_create_session
      android_mock_create_session_w3c
    end

    def android_mock_create_session_w3c
      response = {
        value: {
          sessionId: '1234567890',
          capabilities: {
            platformName: :android,
            automationName: ENV['APPIUM_DRIVER'] || 'uiautomator2',
            app: 'test/functional/app/api.apk.zip',
            platformVersion: '7.1.1',
            deviceName: 'Android Emulator',
            appPackage: 'io.appium.android.apis',
            appActivity: 'io.appium.android.apis.ApiDemos',
            someCapability: 'some_capability'
          }
        }
      }.to_json

      stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
        .with(headers: { 'X-Idempotency-Key' => /.+/ })
        .to_return(headers: HEADER, status: 200, body: response)

      stub_request(:post, "#{SESSION}/timeouts")
        .with(body: { implicit: 5_000 }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

      driver = @core.start_driver

      assert_equal({}, driver.send(:bridge).http.additional_headers)
      assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
      assert_requested(:post, "#{SESSION}/timeouts", body: { implicit: 5_000 }.to_json, times: 1)
      driver
    end

    def ios_mock_create_session
      ios_mock_create_session_w3c
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

      driver = @core.start_driver

      assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
      driver
    end

    def windows_mock_create_session
      response = {
        value: {
          sessionId: '1234567890',
          capabilities: {
            platformName: 'Windows',
            automationNAme: 'Windows',
            deviceName: 'WindowsPC',
            app: 'Microsoft.WindowsCalculator_8wekyb3d8bbwe!App'
          }
        }
      }.to_json

      stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
        .to_return(headers: HEADER, status: 200, body: response)

      driver = @core.start_driver

      assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
      driver
    end

    def windows_mock_create_session_w3c
      response = {
        value: {
          sessionId: '1234567890',
          capabilities: {
            platformName: 'Windows',
            automationNAme: 'Windows',
            deviceName: 'WindowsPC',
            app: 'Microsoft.WindowsCalculator_8wekyb3d8bbwe!App'
          }
        }
      }.to_json

      stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
        .to_return(headers: HEADER, status: 200, body: response)

      driver = @core.start_driver

      assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
      driver
    end

    def mac2_mock_create_session_w3c
      response = {
        value: {
          capabilities: {
            platformName: 'mac',
            automationNAme: 'mac2'
          },
          sessionId: '1234567890'
        }
      }.to_json

      stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
        .to_return(headers: HEADER, status: 200, body: response)

      driver = @core.start_driver

      assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
      driver
    end
  end
end
