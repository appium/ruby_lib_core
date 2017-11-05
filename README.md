# AppiumLibCore

[![Gem Version](https://badge.fury.io/rb/appium_lib_core.svg)](https://badge.fury.io/rb/appium_lib_core)

# Documentation

- http://www.rubydoc.info/github/appium/ruby_lib_core

# Used main library
- https://github.com/appium/ruby_lib

# How to start
## Start Appium server

```bash
$ npm install -g appium
$ appium
```

## Run tests
### Unit Tests

```bash
$ bundle install
$ rake test:unit
```

### Functional Tests

```bash
$ bundle install
$ rake test:func:android # Andorid 
$ rake test:func:ios     # iOS
```

# How to use this core library
1. Launch the appium server locally.
2. Run the following script.

```ruby
require 'rubygems'
require 'appium_lib_core'

opts = {
       caps: {
         platformName: :ios,
         platformVersion: '11.0',
         deviceName: 'iPhone Simulator',
         automationName: 'XCUITest',
         app: '/path/to/MyiOS.app'
       },
       appium_lib: {
       }
     }
@core = Appium::Driver.new(opts) # core driver
@driver = @core.start_driver     # driver extend selenium-webdriver

# Launch iPhone Simulator and `MyiOS.app`
@driver.find_element(:accessibility_id, 'some accessibility') # find an element
```

# Release

```bash
$ bundle exec thor bump # bumpy, bumpz
$ bundle exec thor release
```

# License
Apache License v2
