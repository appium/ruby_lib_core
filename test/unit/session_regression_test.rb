# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'
require 'minitest/mock'

class SessionRegressionTest < Minitest::Test
  URL = 'http://127.0.0.1:4723'

  def attach(platform, automation, id = platform)
    Appium::Core::Driver.attach_to(id, url: URL, platform_name: platform, automation_name: automation)
  end

  def stub_command(id, command, body, value = nil)
    stub_request(:post, "#{URL}/session/#{id}/#{command}")
      .with(body: body)
      .to_return(headers: { 'Content-Type' => 'application/json' }, body: { value: value }.to_json)
  end

  def test_platform_methods_are_isolated_in_both_creation_orders
    [%w(Android iOS), %w(iOS Android)].each do |platforms|
      drivers = platforms.to_h { |platform| [platform, attach(platform, platform == 'Android' ? 'UiAutomator2' : 'XCUITest')] }
      android_request = stub_command('Android', 'appium/start_recording_screen', { options: { timeLimit: '180', bitRate: 1234 } })
      ios_request = stub_command('iOS', 'appium/start_recording_screen', { options: { timeLimit: '180', videoType: 'mjpeg', videoQuality: 'high' } })

      drivers['Android'].start_recording_screen(bit_rate: 1234)
      drivers['iOS'].start_recording_screen(video_quality: 'high')

      assert_requested android_request
      assert_requested ios_request
      WebMock.reset!
    end
  end

  def test_cores_keep_their_extensions_when_started_later
    android = Appium::Core.for(capabilities: { platformName: 'Android', automationName: 'UiAutomator2' })
    Appium::Core.for(capabilities: { platformName: 'iOS', automationName: 'XCUITest' })
    stub_request(:post, "#{URL}/session")
      .to_return(headers: { 'Content-Type' => 'application/json' },
                 body: { value: { sessionId: 'android', capabilities: {} } }.to_json)
    request = stub_command('android', 'appium/start_recording_screen', { options: { timeLimit: '180', bitRate: 1234 } })

    android.start_driver.start_recording_screen(bit_rate: 1234)

    assert_requested request
  end

  def test_windows_and_mac_recording_options_remain_isolated
    windows = attach('Windows', 'Windows')
    mac = attach('mac', 'mac2')
    attach('iOS', 'XCUITest')
    windows_request = stub_command('Windows', 'appium/start_recording_screen', { options: { audioInput: 'microphone' } })
    mac_request = stub_command('mac', 'appium/start_recording_screen', { options: { deviceId: 1 } })

    windows.start_recording_screen(audio_input: 'microphone')
    mac.start_recording_screen(device_id: 1)

    assert_requested windows_request
    assert_requested mac_request
  end

  def test_battery_states_remain_platform_specific
    android = attach('Android', 'UiAutomator2')
    ios = attach('iOS', 'XCUITest')
    %w(Android iOS).each do |id|
      stub_command(id, 'execute/sync', { script: 'mobile: batteryInfo', args: [{}] }, { state: 3, level: 0.5 })
    end

    assert_equal :discharging, android.battery_info[:state]
    assert_equal :full, ios.battery_info[:state]
  end

  def test_relative_app_paths_preserve_capability_keys
    [:app, 'app', :'appium:app', 'appium:app'].each do |key|
      core = Appium::Core.for(capabilities: { key => 'README.md' })

      assert_equal File.expand_path('README.md'), core.caps[key]
      assert_equal({ key.to_s => File.expand_path('README.md') }, core.caps.as_json)
    end
  end

  def test_empty_missing_and_remote_app_paths_are_unchanged
    ['', 'missing.apk', 'https://example.com/app.apk'].each do |app|
      assert_equal app, Appium::Core.for(capabilities: { app: app }).caps[:app]
    end
    assert_empty Appium::Core.for(capabilities: {}).caps.as_json
  end

  def test_context_is_restored_on_exception
    driver = attach('Android', 'UiAutomator2')
    stub_request(:get, "#{URL}/session/Android/context")
      .to_return(headers: { 'Content-Type' => 'application/json' }, body: { value: 'NATIVE_APP' }.to_json)
    stub_command('Android', 'context', { name: 'WEBVIEW' })
    restore = stub_command('Android', 'context', { name: 'NATIVE_APP' })

    error = assert_raises(RuntimeError) do
      driver.within_context('WEBVIEW') { raise 'original failure' }
    end

    assert_equal 'original failure', error.message
    assert_requested restore, times: 1
  end

  def test_attached_driver_wait_defaults
    driver = attach('Android', 'UiAutomator2')

    assert_equal(:ready, driver.wait { :ready })
    assert(driver.wait_true { true })
    assert_raises(Appium::Core::Wait::TimeoutError) do
      driver.wait_true(timeout: 0.001, interval: 0.001) { false }
    end
  end

  def test_direct_connect_ipv6_with_and_without_brackets
    ['2001:db8::1', '[2001:db8::1]'].each do |host|
      client = Appium::Core::Base::Http::Default.new
      client.update_sending_request_to(scheme: 'http', host: host, port: 4723, path: 'wd/hub')

      assert_equal 'http://[2001:db8::1]:4723/wd/hub/', client.send(:server_url).to_s
    end
  end
end
