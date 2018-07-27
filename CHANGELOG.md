# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
### Enhancements
- silence warning for pointeractions [#113](https://github.com/appium/ruby_lib_core/pull/113)

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
