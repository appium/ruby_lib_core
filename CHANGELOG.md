# Changelog
All notable changes to this project will be documented in this file.
Read `release_notes.md` for commit level details.

## [Unreleased]

### Enhancements
- Add `Element#screenshot_as` and `Element#save_screenshot` in Element module
    - They are same as `Driver#element_screenshot_as` and `Driver#save_element_screenshot`

### Bug fixes

### Deprecations

## [4.1.1] - 2020-12-25

### Enhancements
- Ruby 3.0 support
    - Arguments in `@driver.execute_cdp`
        - It should be like `@driver.execute_cdp 'Page.captureScreenshot', quality: 50, format: 'jpeg'` as keyword arguments
          instead of `@driver.execute_cdp 'Page.captureScreenshot', { quality: 50, format: 'jpeg' }` in Ruby 3
          
### Bug fixes

### Deprecations

## [4.0.0] - 2020-12-19

Supported Ruby version is 2.4+

### Enhancements

### Bug fixes

### Deprecations
- No longer work with `forceMjsonwp` capability to force the session MJSONWP

## [3.11.1] - 2020-11-20

### Enhancements

### Bug fixes
- Fix `install_app` to be able to set no args for options

### Deprecations

## [3.11.0] - 2020-08-01

### Enhancements
- Security update [GHSA-2v5c-755p-p4gv](https://github.com/advisories/GHSA-2v5c-755p-p4gv)
    - Affects only _::Appium::Core::WebSocket_

### Bug fixes

### Deprecations

## [3.10.1] - 2020-06-29

### Enhancements

### Bug fixes
- Fix duplication warning of `execute_cdp`

### Deprecations

## [3.10.0] - 2020-06-09

### Enhancements
- Remove deprecated `Selenium::WebDriver::Error::TimeOutError`

### Bug fixes

### Deprecations

## [3.9.0] - 2020-05-31

### Enhancements
- `capabilities:` is available in addition to `desired_capabilities:` and `caps:` as a capability
    ```ruby
    # case 1
    opts = { caps: { }, appium_lib: { } }
    @driver = Appium::Core.for(opts).start_driver

    # case 2
    opts = { capabilities: { }, appium_lib: { } }
    @driver = Appium::Core.for(opts).start_driver

    # case 3
    opts = { desired_capabilities: { }, appium_lib: { } }
    @driver = Appium::Core.for(opts).start_driver
    ```

### Bug fixes

### Deprecations

## [3.8.0] - 2020-05-17

### Enhancements
- Add options for `start_recording_screen`
    - `file_field_name`, `form_fields` and `headers` are available since Appium 1.18.0

### Bug fixes
- Fix `x-idempotency-key` header to add it only in new session request (https://github.com/appium/ruby_lib_core/issues/262)

### Deprecations

## [3.7.0] - 2020-04-18

### Enhancements
- Add `x-idempotency-key` header support (https://github.com/appium/appium-base-driver/pull/400)
    - Can disable the header with `enable_idempotency_header: false` in `appium_lib` capability. Defaults to `true`.
- Add chrome devtools endpoint which is available chrome module in Selenium Ruby binding
    - https://github.com/appium/appium-base-driver/pull/405

### Bug fixes

### Deprecations

## [3.6.1, 3.6.0] - 2020-03-15

### Enhancements
- Add screen record feature for Windows driver (https://github.com/appium/appium-windows-driver/pull/66)
    - `#start_recording_screen`, `#stop_recording_screen`

### Bug fixes

### Deprecations

## [3.5.0] - 2020-01-11

### Enhancements
- Add `:viewmatcher` selector like `@driver.find_elements :view_matcher, { name: 'withText', args: %w(Accessibility), class: 'androidx.test.espresso.matcher.ViewMatchers' }`

### Bug fixes

### Deprecations

## [3.4.2] - 2019-12-29

### Enhancements
- Add `attr_reader :bridge` for flutter driver not to use `send`
   - https://github.com/truongsinh/appium-flutter-driver/pull/35

### Bug fixes

### Deprecations

## [3.4.0, 3.4.1] - 2019-12-26, 2019-12-27

### Enhancements
- Fix Ruby 2.7 warnings

### Bug fixes

### Deprecations

## [3.3.0] - 2019-11-08

### Enhancements
- Add `Logs#event` to post a custom log by `@driver.logs.event vendor: 'appium', event: 'funEvent'`
- Add `Logs#events` to get events by `@driver.logs.events`. It is equal to  `@driver.session_capabilities['events']`

### Bug fixes

### Deprecations

## [3.2.3] - 2019-09-30

### Enhancements
- Add `system_bars` as an alias to `get_system_bars`

### Bug fixes

### Deprecations

## [3.2.2] - 2019-08-04

### Enhancements

### Bug fixes
- Fixed parameters of `remove_app`

### Deprecations

## [3.2.1] - 2019-07-19

### Enhancements
- Add `video_filters` argument for `start_recording_screen` iOS
    - It is available over Appium 1.15.0

### Bug fixes
- Fix wrong warning message in driver detection

### Deprecations
- `Driver#set_immediate_value(element, *value)`
    - Use `Element#immediate_value(*value)` instead
- `Driver#replace_value(element, *value)`
    - Use `Element#replace_value(*value)` instead

## [3.2.0] - 2019-06-27

### Enhancements
- Add `execute_driver` to run a batch script
    - It requires Appium version which has `execute_driver` support

### Bug fixes

### Deprecations

## [3.1.3] - 2019-06-18

### Enhancements
- Add arguments for `start_activity`
    - `intentAction`, `intentCategory`, `intentFlags`, `dontStopAppOnReset`

### Bug fixes

### Deprecations

## [3.1.2] - 2019-05-10

### Enhancements
- Add `sessions` command to get all available sessions on the Appium server
- [internal] Tweak error messages in emulator module

### Bug fixes

### Deprecations

## [3.1.1] - 2019-04-26

### Enhancements
- [internal] Catch `Selenium::WebDriver::Error::TimeoutError` which will be used instead of `Selenium::WebDriver::Error::TimeOutError`

### Bug fixes

### Deprecations

## [3.1.0] - 2019-03-31

### Enhancements
- `tvOS` platform support
    - `platformName: :tvos, automationName: :xcuitest` can work for iOS tvOS
    - It requires Appium 1.13

### Bug fixes

### Deprecations

## [3.0.4] - 2019-03-24

### Enhancements
- Add `pixelFormat` argument in screen record for iOS

### Bug fixes

### Deprecations

## [3.0.3] - 2019-03-11

### Enhancements
- [internal] Bump Rubocop target Ruby version to Ruby 2.3

### Bug fixes

### Deprecations

## [3.0.2] - 2019-03-07

### Enhancements
- Append more examples for use case in `test/functional` as functional test cases

### Bug fixes
- [internal] Fixed typo in `Emulator#gsm_signal` [#196](https://github.com/appium/ruby_lib_core/pull/196)
    - Thanks [khanhdodang](https://github.com/khanhdodang)

### Deprecations

## [3.0.1] - 2019-02-25

### Enhancements
- Add `:data_matcher` find_element/s attribute [appium-espresso-driver#386](https://github.com/appium/appium-espresso-driver/pull/386)

### Bug fixes

### Deprecations

## [3.0.0] - 2019-02-06

This release has a breaking change about an implicit wait.
Ruby client sets `0` seconds as implicit wait by default instead of `20` seconds.
The behaviour follows the default spec in WebDriver.

### Enhancements
- **Breaking changes**
    - Set implicit wait zero by default [#186](https://github.com/appium/ruby_lib_core/pull/186)
        - Can configure `wait: 20` as `appium_lib` capability to keep the behaviour
- [Experimental] Add `direct_connect` capability for the Ruby client in order to handle `directConnect` capability in a create session response by Appium server [#189](https://github.com/appium/ruby_lib_core/pull/189)
    - Update http client following `directConnectProtocol`, `directConnectHost`, `directConnectPort` and `directConnectPath`
      if `direct_connect` capability for ruby_lib_core is `true`
    - This will resolve a performance issue if a user has a proxy server to handle requests from client to Appium server.
      With this feature, the user can send requests directly to the Appium server after create session skipping the proxy server.
      ```
      # create session
      client <---> proxy server <---> appium server <> devices
      # Following requests after the create session
      client <----------------------> appium server <> devices
      ```

### Bug fixes
- Fix potential override of `AppManagement#background_app` [#188](https://github.com/appium/ruby_lib_core/pull/188)

### Deprecations

## [2.3.4] - 2019-01-31
### Enhancements
- Add 3D touch option for `TouchAction#press` [appium/WebDriverAgent#79](https://github.com/appium/WebDriverAgent/pull/79)
    - `:pressure` option

### Bug fixes
- Stop sending blank value in `start_activity`

### Deprecations

## [2.3.3] - 2019-01-22
### Enhancements

### Bug fixes
- Add `*args, &block` in method missing in `Selenium::WebDriver::Element` [#184](https://github.com/appium/ruby_lib_core/pull/184)

### Deprecations

## [2.3.2] - 2019-01-20
### Enhancements
- Add alias for some method calls
    1. IME: e.g. `@driver.ime.activate` in addition to  `@driver.ime_activate` [rubydoc](https://www.rubydoc.info/github/appium/ruby_lib_core/master/Appium/Core/Base/Driver#ime-instance_method)
    2. Settings: e.g. `@driver.settings = { ... }` and  `@driver.settings.update(...)` in addition to `@driver.update_settings(...)` [rubydoc](https://www.rubydoc.info/github/appium/ruby_lib_core/master/Appium/Core/Base/Driver#settings-instance_method)
    3. Locked: `@driver.locked?` in addition to `@driver.device_locked?`

### Bug fixes
-  `ServerError` inherits `CoreError` in order to handle it as an exception

### Deprecations

## [2.3.1] - 2019-01-13
### Enhancements
- `set_network_connection` accepts keys as same as `network_connection_type` in addition to numbers
    - `{ :airplane_mode: 1, wifi: 2, data: 4, all: 6, none: 0 }`
    - Read [documentation](https://www.rubydoc.info/github/appium/ruby_lib_core/master/Appium/Core/Android/Device#set_network_connection-instance_method) more

### Bug fixes

### Deprecations

## [2.3.0] - 2019-01-07
### Enhancements
- Use `Base64.strict_encode64` when this client sends `Base64` encoded data to server
    - Follows RFC 4648 format. It should not affect server side which is front Appium node server
    - Continues to decode base 64 data following `decode64` to accept RFC 2045 format
- Add `query_app_state` as an alias of `app_state` to get application status

### Bug fixes

### Deprecations

## [2.2.2] - 2018-12-22
### Enhancements
- Append `appium` in header: `appium/ruby_lib_core/2.2.1 (selenium/3.141.0 (ruby macosx))`

### Bug fixes

### Deprecations

## [2.2.1] - 2018-12-08
### Enhancements

### Bug fixes
- Reduce warnings for method definitions

### Deprecations

## [2.2.0] - 2018-12-01
### Enhancements
- Add `::Appium::Core::Base.platform` to call `::Selenium::WebDriver::Platform`
    - Can identify platform using `::Appium::Core::Base.platform.windows?` for example

### Bug fixes

### Deprecations
- `:offset_x` and `:offset_y` in `TouchAction#swipe` is deprecated in favor of `:end_x` and `:end_y`

## [2.1.1] - 2018-11-23
### Enhancements
- `desired_capabilities:` is available in addition to `caps:` as a capability
    ```ruby
    # case 1
    opts = { caps: { }, appium_lib: { } }
    @driver = Appium::Core.for(opts).start_driver

    # case 2
    opts = { desired_capabilities: { }, appium_lib: { } }
    @driver = Appium::Core.for(opts).start_driver
    ```
- Update `start_recording_screen` for iOS, Appium 1.10.0
    - Add `:video_scale` and update `:video_type`

### Bug fixes

### Deprecations

## [2.1.0] - 2018-11-14
### Enhancements
- Support below style _1_, has _url_ parameter, in addition to style _2_
    ```
    # 1
    Appium::Core.for url: "http://127.0.0.1:8080/wd/hub", caps: {...}, appium_lib: {...}

    # 2
    Appium::Core.for caps: {...}, appium_lib: {...}
    ```
- Add `:video_fps` param for screen recording in iOS(XCUITest) to sync with Appium 1.10.0

### Bug fixes

### Deprecations

## [2.0.6] - 2018-11-08
### Enhancements
- Allow selenium update following Pi versioning like 3.141.0
- [internal] Update dev libraries

### Bug fixes

### Deprecations

## [2.0.5] - 2018-10-30
### Enhancements
- [internal] No longer send `strategy: :tapOutside` as default value in Android

### Bug fixes

### Deprecations

## [2.0.4] - 2018-10-19
### Enhancements
- Add custom locator in the future work: [element-finding-plugins](https://github.com/appium/appium/blob/master/docs/en/advanced-concepts/element-finding-plugins.md)
    - https://github.com/appium/appium-base-driver/pull/268/
    ```
    @driver.find_element :custom, "f:foo"

    ```

### Bug fixes

### Deprecations

## [2.0.3] - 2018-10-11
### Enhancements
- Set `'selenium-webdriver', '~> 3.14.1'`

### Bug fixes

### Deprecations

## [2.0.2] - 2018-10-02
### Enhancements
- Add finger print feature for Android emulators [#13](https://github.com/appium/ruby_lib_core/issues/13)
- Add `keyboard_shown?` and `context=` as aliases of `is_keyboard_shown` and `set_contex`

### Bug fixes

### Deprecations

## [2.0.1] - 2018-09-01
### Enhancements
- Add `Appium::Core::Base::Driver#perform_actions` to send multiple actions. See `test_multiple_actions` as an example.

### Bug fixes
- Fix desired capability for W3C protocol under selenium grid environment [#137](https://github.com/appium/ruby_lib_core/issues/137)

### Deprecations

## [2.0.0] - 2018-08-25

This release has a breaking change for creating core. Thus, I've bumped the major version.

### Enhancements
- use `autoload` to load Android/iOS modules

### Bug fixes

### Deprecations
- `@core = Appium::Core.for(self, opts)` is deprecated in favor of `@core = Appium::Core.for(opts)`
    - Call `extend Appium::Core::Device` if you'd like to extend methods defined in `Appium::Core`
        - Read [#816](https://github.com/appium/ruby_lib/pull/816) as an example

## [1.9.2] - 2018-08-23
### Enhancements

### Bug fixes
- fix unexpedted method missing against `:to_hash` in Element

### Deprecations

## [1.9.1] - 2018-08-20
### Enhancements
- Add `:viewtag` for Espresso driver [appium-espresso-driver#189](https://github.com/appium/appium-espresso-driver/pull/189)
- Add missing `take_viewport_screenshot` for mjsonwp [#127](https://github.com/appium/ruby_lib_core/pull/127)

### Bug fixes
- [internal] Fix raising error in `set_implicit_wait_by_default` [#130](https://github.com/appium/ruby_lib_core/issues/130)

### Deprecations

## [1.9.0] - 2018-08-05
### Enhancements
- Update documentation about `start_recording_screen`
- Port `send_keys/type` for active element [#122](https://github.com/appium/ruby_lib_core/pull/122)
- Support `find_element/s :image, partial_image` [#119](https://github.com/appium/ruby_lib_core/pull/119)
- Requires `selenium-webdriver 3.14+` because of W3C actions [#115](https://github.com/appium/ruby_lib_core/pull/115)

### Bug fixes

### Deprecations
- [Internal] Deprecate experimental `ImageElement` in favor of `Element`

## [1.8.4] - 2018-07-28
### Enhancements
- silence warning for pointeractions [#113](https://github.com/appium/ruby_lib_core/pull/113)
- Use method missing to get attributes like `e.resource_id` instead of `e.attribute 'resource-id'` [#116](https://github.com/appium/ruby_lib_core/pull/116)
- Set `'~> 3.5', '< 3.14'`

### Bug fixes

### Deprecations

## [1.8.3] - 2018-07-20
### Enhancements
- Relax the logic of `:app` capability

### Bug fixes
- Fix `within_context`

### Deprecations

## [1.8.2] - 2018-07-17
### Enhancements

### Bug fixes
- Available packages over HTTP [#106](https://github.com/appium/ruby_lib_core/issues/106)

### Deprecations
- Remove warning of camelCase capability for W3C format

## [1.8.1] - 2018-07-13
### Enhancements

### Bug fixes
- Fix including search context in `::Selenium::WebDriver::Elemenet`
    - `include ::Appium::Core::Base::SearchContext` instead of `::Selenium::WebDriver::SearchContext`

### Deprecations

## [1.8.0] - 2018-07-07
### Enhancements
- Add Tizen case
- [Internal] reduce method definition by `add_endpoint_method`

### Bug fixes

### Deprecations

## [1.7.2] - 2018-06-23
### Enhancements
- Add `find_element_by_image` and `find_elements_by_image` to handle `ImageElement`
   - Read [here](https://github.com/appium/ruby_lib_core/blob/a08c7c769d12316f3a410b28f93799682a111ed8/lib/appium_lib_core/common/base/driver.rb#L191-L257) for more details
- Add a `ImageElement` to handle images as elements by `matchTemplate`
   - Experimental feature
- [Internal] Define screenshot methods in appium_lib_core instead of Selenium's one

### Bug fixes

### Deprecations

## [1.7.1] - 2018-06-15
### Enhancements
- Add a `format` argument for `device_time` [#94](https://github.com/appium/ruby_lib_core/pull/94)

### Bug fixes
- Return empty array `[]` for find_elements

### Deprecations

## [1.7.0] - 2018-05-28
### Enhancements
- Has one **Breaking Change**
    - Add `flags` in `press_keycode` and `long_press_keycode`
       - New: `@driver.press_keycode 66, metastate: [1], flags: [0x20, 0x2000]`
          - `metastate` should set as a keyword argument
          - `long_press_keycode` as well
       - Before: `@driver.press_keycode 66, 1` (Can set only metastate)
          - How to change: add `metastate:` for the metastate argument
- [Internal] Change directory and file structure
- [Internal] Set default content-type

### Bug fixes

### Deprecations

## [1.6.0] - 2018-05-08
### Enhancements
- **Breaking Change**
    - Change the results of `app_state`.
        - Before: A number or const.
            - `0, 1, 2, 3, 4` or `NOT_INSTALLED, NOT_RUNNING, RUNNING_IN_BACKGROUND_SUSPENDED, RUNNING_IN_BACKGROUND, RUNNING_IN_FOREGROUND`
        - After: Symbol.
            - `:not_installed, :not_running, :running_in_background_suspended, :running_in_background, :running_in_foreground`
- add `battery_info` to get battery information
- add `is_keyboard_shown` for iOS ( see also https://github.com/appium/appium-xcuitest-driver/pull/664/files )

### Bug fixes

### Deprecations

## [1.5.1] - 2018-04-25
### Enhancements

### Bug fixes
- Revert timeout logic in `1.4.1`

### Deprecations

## [1.5.0] - 2018-04-25
### Enhancements
- [internal] Remove hot fix for XCUITest action

### Bug fixes

### Deprecations
- Changed the name of arguments
    - `swipe(start_x:, start_y:, end_x:, end_y:)` instead of `swipe(start_x:, start_y:, offset_x:, offset_y:)`

## [1.4.2] - 2018-04-22
### Enhancements

### Bug fixes
- Revert `delegate_from_appium_driver` for `ruby_lib` compatibility

### Deprecations

## [1.4.1] - 2018-04-22
### Enhancements
- add base image comparison
    - `match_images_features`, `find_image_occurrence`, `get_images_similarity`, `compare_images`
- [internal] No longer have dependency for Selenium's wait
    - Raise `::Appium::Core::Wait::TimeoutError` instead of `::Selenium::WebDriver::Error::TimeOutError`
- [internal] Separate mjsonwp commands module and w3c commands module from one command module

### Bug fixes

### Deprecations

## [1.4.0] - 2018-04-15
### Enhancements
- Add a support for WebSocket client based on Faye::WebSocket::Client [#74](https://github.com/appium/ruby_lib_core/pull/74)

### Bug fixes

### Deprecations

## [1.3.8] - 2018-04-12
### Enhancements
- Make no-argument commands friendly for IDE

### Bug fixes

### Deprecations

## [1.3.7] - 2018-04-02
### Enhancements
- Only for `ruby_lib_core` internal process
    - Remove `touch` action by default and following `selenium-webdriver` in W3C action.
        - Since XCUITest and UA2 drivers force handling the pointer as `touch`.

### Bug fixes

### Deprecations

## [1.3.6] - 2018-04-01
### Enhancements
- Be able to change `kind` in W3C touch action.
    - Read: https://github.com/appium/ruby_lib_core/blob/master/lib/appium_lib_core/common/base/bridge/w3c.rb#L29

### Bug fixes

### Deprecations

## [1.3.5] - 2018-03-30
### Enhancements
- Add a `bug_report` option in `start_recording_screen`, Android
- Add clipboard apis [#69](https://github.com/appium/ruby_lib_core/pull/69)

### Bug fixes

### Deprecations

## [1.3.4] - 2018-03-21
### Enhancements
- Add `save_viewport_screenshot` which get screenshot except for status bar.
    - https://github.com/search?q=org%3Aappium+viewportScreenshot&type=Code
- [iOS] Add `start_performance_record` and `get_performance_record`

### Bug fixes
- Fix _create_session attempt to throw non-existent error type Appium::Core::Error::WebDriverError_ [#66](https://github.com/appium/ruby_lib_core/issues/66)

### Deprecations

## [1.3.3] - 2018-03-03
### Enhancements
- add `session_capabilities`: https://appium.io/docs/en/commands/session/get/

### Bug fixes

### Deprecations

## [1.3.2] - 2018-02-18
### Enhancements
- Add Android emulator commands
    - `send_sms`, `gsm_call`, `gsm_signal`, `gsm_voice`, `set_network_speed`, `set_power_capacity`, `set_power_ac`
- Add toggles
    - `toggle_location_services`, `toggle_wifi`, `toggle_data`

### Bug fixes

### Deprecations

## [1.3.1] - 2018-02-14
### Enhancements
- add some app management commands [#58](https://github.com/appium/ruby_lib_core/pull/58)
    - Require Appium 1.8.0+
- Both platforms work absolute based axis for `move_to` and `swipe`
    - **Breaking Changes**
        - Android was relevant, previously.
        - e.g.:
            ```ruby
            # Do not move because of the start and end point is the same
            # Tap (75, 500) and move the point to (75, 500) with duration 500ms.
            Appium::Core::TouchAction.new(@driver)
              .swipe(start_x: 75, start_y: 500, offset_x: 75, offset_y: 500, duration: 500)
              .perform

            # Tap (75, 500) and move the point to (75, 1000) with duration 500ms.
            Appium::Core::TouchAction.new(@driver)
              .swipe(start_x: 75, start_y: 500, offset_x: 75, offset_y: 1000, duration: 500)
              .perform
            ```

### Bug fixes

### Deprecations

## [1.3.0] - 2018-01-28
### Enhancements
- `start_recording_screen`/`stop_recording_screen` support iOS from `Appium 1.8.0` [#48](https://github.com/appium/ruby_lib_core/issues/48)
    - **Breaking Changes**
        - `start_recording_screen`
            - The argument, `file_path`, was removed.

### Bug fixes

### Deprecations

## [1.2.7] - 2018-01-25
### Enhancements
- Print warning messages to use camelCase if capability key names are snake_case
    - For W3C adaption for Appium Server

### Bug fixes
- Make `@driver.automation_name` downcase [#50](https://github.com/appium/ruby_lib_core/issues/50)

### Deprecations

## [1.2.6] - 2018-01-21
### Enhancements
- Add `window_rect`

### Bug fixes
- Make `@driver.automation_name` symbol when someone define the `automationName` with the server argument. [#50](https://github.com/appium/ruby_lib_core/issues/50)

### Deprecations

## [1.2.5] - 2018-01-13
### Enhancements
- Enhance W3C support
    - Timeout related methods

### Bug fixes

### Deprecations

## [1.2.4] - 2018-01-03
### Enhancements
- Refactor `create_session` in `Appium::Core::Base::Bridge`
- Be able to communicate with Appium by `W3C` based webdriver protocol if the Appium supports W3C protocol.
    - If `forceMjsonwp: true` exists in the capability, the client try to communicate `mjsonwp` based protocol
        - By default, it depends on the response from the server
    - Read API doc for `Appium::Core::Base::Bridge#create_session` to read the example of `forceMjsonwp`
- Backport some commands from OSS module to W3C module
    - Read `lib/appium_lib_core/common/base/w3c_bridge.rb` for more details
- Can get logs like `driver.logs.available_types` and `driver.logs.get`

### Bug fixes

### Deprecations

## [1.2.3] - 2017-12-27
### Enhancements

### Bug fixes
- Fix some w3c methods to work with Appium part 2 [#38](https://github.com/appium/ruby_lib_core/pull/38)

### Deprecations

## [1.2.2] - 2017-12-25
### Enhancements

### Bug fixes
- Fix some w3c methods to work with Appium [#37](https://github.com/appium/ruby_lib_core/pull/37)

### Deprecations

## [1.2.1] - 2017-12-23
### Enhancements
- override default duration to make some action fast [#36](https://github.com/appium/ruby_lib_core/pull/36)

### Bug fixes

### Deprecations

## [1.2.0] - 2017-12-23
### Enhancements
- Append `appium:` prefix for capabilities automatically due to W3C format.
- add take element screenshot for oss module [#33](https://github.com/appium/ruby_lib_core/pull/33)
- add w3c touch action tests and some supports for w3c [#35](https://github.com/appium/ruby_lib_core/pull/35)
    - IME related
    - Touch actions based on W3C spec

### Bug fixes

### Deprecations

## [1.1.0] - 2017-12-16
### Enhancements
- Add guidelines in `.github`
- session/:session_id/appium/device/keyevent [#21](https://github.com/appium/ruby_lib_core/issues/21)

### Bug fixes
- fix creating sessions [#31](https://github.com/appium/ruby_lib_core/pull/31) for W3C creating sessions

### Deprecations

## [1.0.0] - 2017-11-12

Initial release
