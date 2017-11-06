# AppiumLibCore

[![Gem Version](https://badge.fury.io/rb/appium_lib_core.svg)](https://badge.fury.io/rb/appium_lib_core)


[![Build Status](https://travis-ci.org/appium/ruby_lib_core.svg?branch=master)](https://travis-ci.org/appium/ruby_lib_core)

# Documentation

- http://www.rubydoc.info/github/appium/ruby_lib_core

# Related library
- https://github.com/appium/ruby_lib

# How to start
## Run tests
### Unit Tests
Run unit tests which check each method and commands, URL, using the webmock.

```bash
$ bundle install
$ rake test:unit
```

### Functional Tests
Run functional tests which require the Appium server and real device, Simulator/Emulator.

- Start Appium server
 ```bash
$ npm install -g appium
$ appium
```

- Conduct tests
 ```bash
$ bundle install
$ rake test:func:android # Andorid 
$ rake test:func:ios     # iOS
```

## Run a test case
1. Launch the Appium server locally.
2. Run the following script.

- `test.rb`
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
    wait: 30
  }
}
@core = Appium::Core.for(self, opts) # create a core driver with `opts` and extend methods into `self`
@driver = @core.start_driver

# Launch iPhone Simulator and `MyiOS.app`
@driver.find_element(:accessibility_id, 'some accessibility') # find an element
```

- Run the script
```bash
# shell 1
$ appium

# shell 2
$ ruby test.rb
```

# Release
Use [appium_thor](https://github.com/appium/appium_thor) to release this gem.

```bash
$ bundle exec thor bump # bumpy, bumpz
$ bundle exec thor release
```

# Contribution
1. Fork it ( https://github.com/appium/ruby_lib_core/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

# License
Apache License v2
