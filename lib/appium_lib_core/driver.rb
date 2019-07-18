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

require 'uri'

module Appium
  module Core
    module Android
      autoload :Uiautomator1, 'appium_lib_core/android'
      autoload :Uiautomator2, 'appium_lib_core/android_uiautomator2'
      autoload :Espresso, 'appium_lib_core/android_espresso'
    end

    module Ios
      autoload :Uiautomation, 'appium_lib_core/ios'
      autoload :Xcuitest, 'appium_lib_core/ios_xcuitest'
    end

    # This options affects only client side as <code>:appium_lib</code> key.<br>
    # Read {::Appium::Core::Driver} about each attribute
    class Options
      attr_reader :custom_url, :default_wait, :export_session, :export_session_path,
                  :port, :wait_timeout, :wait_interval, :listener,
                  :direct_connect

      def initialize(appium_lib_opts)
        @custom_url = appium_lib_opts.fetch :server_url, nil
        @default_wait = appium_lib_opts.fetch :wait, Driver::DEFAULT_IMPLICIT_WAIT

        # bump current session id into a particular file
        @export_session = appium_lib_opts.fetch :export_session, false
        @export_session_path = appium_lib_opts.fetch :export_session_path, default_tmp_appium_lib_session

        @direct_connect = appium_lib_opts.fetch :direct_connect, false

        @port = appium_lib_opts.fetch :port, Driver::DEFAULT_APPIUM_PORT

        # timeout and interval used in ::Appium::Comm.wait/wait_true
        @wait_timeout  = appium_lib_opts.fetch :wait_timeout, ::Appium::Core::Wait::DEFAULT_TIMEOUT
        @wait_interval = appium_lib_opts.fetch :wait_interval, ::Appium::Core::Wait::DEFAULT_INTERVAL

        # to pass it in Selenium.new.
        # 'listener = opts.delete(:listener)' is called in Selenium::Driver.new
        @listener = appium_lib_opts.fetch :listener, nil
      end

      private

      def default_tmp_appium_lib_session
        ::Appium::Core::Base.platform.windows? ? 'C:\\\\Windows\\Temp\\appium_lib_session' : '/tmp/appium_lib_session'
      end
    end

    # DirectConnections has capabilities of directConnect
    class DirectConnections
      KEYS = {
        protocol: 'directConnectProtocol',
        host: 'directConnectHost',
        port: 'directConnectPort',
        path: 'directConnectPath'
      }.freeze

      # @return [string] Returns a protocol such as http/https
      attr_reader :protocol

      # @return [string] Returns a host name such as io.appium
      attr_reader :host

      # @return [integer] Returns a port number such as 443
      attr_reader :port

      # @return [string] Returns a path for webdriver such as <code>/hub/wd</code>
      attr_reader :path

      def initialize(capabilities)
        @protocol = capabilities[KEYS[:protocol]]
        @host = capabilities[KEYS[:host]]
        @port = capabilities[KEYS[:port]]
        @path = capabilities[KEYS[:path]]
      end
    end

    class Driver
      include Waitable
      # Selenium webdriver capabilities
      # @return [Core::Base::Capabilities]
      attr_reader :caps

      # Return http client called in start_driver()
      # @return [Appium::Core::Base::Http::Default] the http client
      attr_reader :http_client

      # Device type to request from the appium server
      # @return [Symbol] :android and :ios, for example
      attr_reader :device

      # Automation name sent to appium server or received by server.<br>
      # If automation_name is <code>nil</code>, it is not set both client side and server side.
      # @return [Hash]
      attr_reader :automation_name

      # Custom URL for the selenium server. If set this attribute, ruby_lib_core try to handshake to the custom url.<br>
      # Defaults to false. Then try to connect to <code>http://127.0.0.1:#{port}/wd/hub<code>.
      # @return [String]
      attr_reader :custom_url

      # Export session id to textfile in /tmp for 3rd party tools. False bu default.
      # @return [Boolean]
      attr_reader :export_session
      # @return [String] By default, session id is exported in '/tmp/appium_lib_session'
      attr_reader :export_session_path

      # Default wait time for elements to appear in Appium server side.
      # Defaults to {::Appium::Core::Driver::DEFAULT_IMPLICIT_WAIT}.<br>
      # Provide <code>{ appium_lib: { wait: 30 } }</code> to {::Appium::Core.for}
      # @return [Integer]
      attr_reader :default_wait
      DEFAULT_IMPLICIT_WAIT = 0

      # Appium's server port. 4723 is by default. Defaults to {::Appium::Core::Driver::DEFAULT_APPIUM_PORT}.<br>
      # Provide <code>{ appium_lib: { port: 8080 } }</code> to {::Appium::Core.for}.
      # <code>:custom_url</code> is prior than <code>:port</code> if <code>:custom_url</code> is set.
      # @return [Integer]
      attr_reader :port
      DEFAULT_APPIUM_PORT = 4723

      # Return a time wait timeout. 30 seconds is by default {::Appium::Core::Wait::DEFAULT_TIMEOUT}.<br>
      # Wait time for {::Appium::Core::Base::Wait}, wait and wait_true.<br>
      # Provide <code>{ appium_lib: { wait_timeout: 20 } }</code> to {::Appium::Core.for}.
      # @return [Integer]
      attr_reader :wait_timeout

      # Return a time to wait interval. 0.5 seconds is by default {::Appium::Core::Wait::DEFAULT_INTERVAL}.<br>
      # Wait interval time for {::Appium::Core::Base::Wait}, wait and wait_true.<br>
      # Provide <code>{ appium_lib: { wait_interval: 0.1 } }</code> to {::Appium::Core.for}.
      # @return [Integer]
      attr_reader :wait_interval

      # instance of AbstractEventListener for logging support
      # Nil by default
      attr_reader :listener

      # @return [Appium::Core::Base::Driver]
      attr_reader :driver

      # <b>[Experimental feature]</b><br>
      # Enable an experimental feature updating Http client endpoint following below keys by Appium/Selenium server.<br>
      # This works with {Appium::Core::Base::Http::Default}.
      #
      # If your Selenium/Appium server decorates the new session capabilities response with the following keys:<br>
      # - <code>directConnectProtocol</code>
      # - <code>directConnectHost</code>
      # - <code>directConnectPort</code>
      # - <code>directConnectPath</code>
      #
      # Ignore them if this parameter is <code>false</code>. Defaults to false.
      #
      # @return [Bool]
      attr_reader :direct_connect

      # Creates a new driver and extend particular methods
      # @param [Hash] opts A options include capabilities for the Appium Server and for the client.
      # @option opts [Hash] :caps Appium capabilities. Prior than :desired_capabilities
      # @option opts [Hash] :desired_capabilities The same as :caps.
      #                                           This param is for compatibility with Selenium WebDriver format
      # @option opts [Appium::Core::Options] :appium_lib Capabilities affect only ruby client
      # @option opts [String] :url The same as :custom_url in :appium_lib.
      #                            This param is for compatibility with Selenium WebDriver format
      #
      # @return [Driver]
      #
      # @example
      #
      #     # format 1
      #     @core = Appium::Core.for caps: {...}, appium_lib: {...}
      #     # format 2. 'desired_capabilities:' is also available instead of 'caps:'. Either is fine.
      #     @core = Appium::Core.for url: "http://127.0.0.1:8080/wd/hub", desired_capabilities: {...}, appium_lib: {...}
      #     # format 3. 'appium_lib: {...}' can be blank
      #     @core = Appium::Core.for url: "http://127.0.0.1:8080/wd/hub", desired_capabilities: {...}
      #
      #
      #     require 'rubygems'
      #     require 'appium_lib_core'
      #
      #     # Start iOS driver
      #     opts = {
      #              caps: {
      #                platformName: :ios,
      #                platformVersion: '11.0',
      #                deviceName: 'iPhone Simulator',
      #                automationName: 'XCUITest',
      #                app: '/path/to/MyiOS.app'
      #              },
      #              appium_lib: {
      #                export_session: false,
      #                port: 8080,
      #                wait: 0,
      #                wait_timeout: 20,
      #                wait_interval: 0.3,
      #                listener: nil,
      #              }
      #            }
      #     @core = Appium::Core.for(opts) # create a core driver with 'opts' and extend methods into 'self'
      #     @core.start_driver # Connect to 'http://127.0.0.1:8080/wd/hub' because of 'port: 8080'
      #
      #     # Start iOS driver with .zip file over HTTP
      #     #  'desired_capabilities:' is also available instead of 'caps:'. Either is fine.
      #     opts = {
      #              desired_capabilities: {
      #                platformName: :ios,
      #                platformVersion: '11.0',
      #                deviceName: 'iPhone Simulator',
      #                automationName: 'XCUITest',
      #                app: 'http://example.com/path/to/MyiOS.app.zip'
      #              },
      #              appium_lib: {
      #                server_url: 'http://custom-host:8080/wd/hub.com',
      #                export_session: false,
      #                wait: 0,
      #                wait_timeout: 20,
      #                wait_interval: 0.3,
      #                listener: nil,
      #              }
      #            }
      #     @core = Appium::Core.for(opts)
      #     @core.start_driver # Connect to 'http://custom-host:8080/wd/hub.com'
      #
      #     # Start iOS driver as another format. 'url' is available like below
      #     opts = {
      #              url: "http://custom-host:8080/wd/hub.com",
      #              desired_capabilities: {
      #                platformName: :ios,
      #                platformVersion: '11.0',
      #                deviceName: 'iPhone Simulator',
      #                automationName: 'XCUITest',
      #                app: '/path/to/MyiOS.app'
      #              },
      #              appium_lib: {
      #                export_session: false,
      #                wait: 0,
      #                wait_timeout: 20,
      #                wait_interval: 0.3,
      #                listener: nil,
      #              }
      #            }
      #     @core = Appium::Core.for(opts) # create a core driver with 'opts' and extend methods into 'self'
      #     @core.start_driver # start driver with 'url'. Connect to 'http://custom-host:8080/wd/hub.com'
      #
      def self.for(opts = {})
        new(opts)
      end

      private

      # @private
      # For testing purpose of delegate_from_appium_driver
      def delegated_target_for_test
        @delegate_target
      end

      public

      # @private
      def initialize(opts = {})
        @delegate_target = self # for testing purpose
        @automation_name = nil # initialise before 'set_automation_name'

        opts = Appium.symbolize_keys opts
        validate_keys(opts)

        @custom_url = opts.delete :url
        @caps = get_caps(opts)

        set_appium_lib_specific_values(get_appium_lib_opts(opts))
        set_app_path
        set_appium_device
        set_automation_name

        extend_for(device: @device, automation_name: @automation_name)

        self # rubocop:disable Lint/Void
      end

      # Creates a new global driver and quits the old one if it exists.
      # You can customise http_client as the following
      #
      # @param [String] server_url Custom server url to send to requests. Default is "http://127.0.0.1:4723/wd/hub".
      # @param http_client_ops [Hash] Options for http client
      # @option http_client_ops [Hash] :http_client Custom HTTP Client
      # @option http_client_ops [Hash] :open_timeout Custom open timeout for http client.
      # @option http_client_ops [Hash] :read_timeout Custom read timeout for http client.
      # @return [Selenium::WebDriver] the new global driver
      #
      # @example
      #
      #     require 'rubygems'
      #     require 'appium_lib_core'
      #
      #     # platformName takes a string or a symbol.
      #
      #     # Start iOS driver
      #     opts = {
      #              caps: {
      #                platformName: :ios,
      #                platformVersion: '11.0',
      #                deviceName: 'iPhone Simulator',
      #                automationName: 'XCUITest',
      #                app: '/path/to/MyiOS.app'
      #              },
      #              appium_lib: {
      #                wait: 20,
      #                wait_timeout: 20,
      #                wait_interval: 0.3,
      #              }
      #            }
      #
      #     @core = Appium::Core.for(opts) # create a core driver with 'opts' and extend methods into 'self'
      #     @driver = @core.start_driver server_url: "http://127.0.0.1:8000/wd/hub"
      #
      #     # Attach custom HTTP client
      #     @driver = @core.start_driver server_url: "http://127.0.0.1:8000/wd/hub",
      #                                  http_client_ops: { http_client: Your:Http:Client.new,
      #                                                     open_timeout: 1_000,
      #                                                     read_timeout: 1_000 }
      #

      def start_driver(server_url: nil,
                       http_client_ops: { http_client: nil, open_timeout: 999_999, read_timeout: 999_999 })
        @custom_url ||= server_url || "http://127.0.0.1:#{@port}/wd/hub"

        create_http_client http_client: http_client_ops.delete(:http_client),
                           open_timeout: http_client_ops.delete(:open_timeout),
                           read_timeout: http_client_ops.delete(:read_timeout)

        begin
          # included https://github.com/SeleniumHQ/selenium/blob/43f8b3f66e7e01124eff6a5805269ee441f65707/rb/lib/selenium/webdriver/remote/driver.rb#L29
          @driver = ::Appium::Core::Base::Driver.new(http_client: @http_client,
                                                     desired_capabilities: @caps,
                                                     url: @custom_url,
                                                     listener: @listener)

          if @direct_connect
            d_c = DirectConnections.new(@driver.capabilities)
            @driver.update_sending_request_to(protocol: d_c.protocol, host: d_c.host, port: d_c.port, path: d_c.path)
          end

          # export session
          write_session_id(@driver.session_id, @export_session_path) if @export_session
        rescue Errno::ECONNREFUSED
          raise "ERROR: Unable to connect to Appium. Is the server running on #{@custom_url}?"
        end

        # If "automationName" is set only server side, this method set "automationName" attribute into @automation_name.
        # Since @automation_name is set only client side before start_driver is called.
        set_automation_name_if_nil

        set_implicit_wait_by_default(@default_wait)

        @driver
      end

      private

      def create_http_client(http_client: nil, open_timeout: nil, read_timeout: nil)
        @http_client = http_client || Appium::Core::Base::Http::Default.new

        # open_timeout and read_timeout are explicit wait.
        @http_client.open_timeout = open_timeout if open_timeout
        @http_client.read_timeout = read_timeout if read_timeout
      end

      # Ignore setting default wait if the target driver has no implementation
      def set_implicit_wait_by_default(wait)
        @driver.manage.timeouts.implicit_wait = wait
      rescue ::Selenium::WebDriver::Error::UnknownError => e
        unless e.message.include?('The operation requested is not yet implemented')
          raise ::Appium::Core::Error::ServerError, e.message
        end

        ::Appium::Logger.debug(e.message)
        {}
      end

      public

      # Quits the driver
      # @return [void]
      #
      # @example
      #
      #   @core.quit_driver
      #
      def quit_driver
        @driver.quit
      rescue # rubocop:disable Style/RescueStandardError
        nil
      end

      # Returns the server's version info
      # @return [Hash]
      #
      # @example
      #
      #   @core.appium_server_version
      #     {
      #         "build" => {
      #             "version" => "1.9.2",
      #             "git-sha" => "fd7c7fd19d3896719616cd970229d73e63b5271a",
      #             "built" => "2018-11-08 12:24:02 +0900"
      #         }
      #     }
      #
      # Returns blank hash for Selenium Grid since 'remote_status' gets 500 error
      #
      # @example
      #
      #   @core.appium_server_version #=> {}
      #
      def appium_server_version
        @driver.remote_status
      rescue Selenium::WebDriver::Error::ServerError => e
        raise ::Appium::Core::Error::ServerError unless e.message.include?('status code 500')

        # driver.remote_status returns 500 error for using selenium grid
        {}
      end

      # Return the platform version as an array of integers
      # @return [Array<Integer>]
      #
      # @example
      #
      #     @core.platform_version #=> [10,1,1]
      #
      def platform_version
        p_version = @driver.capabilities['platformVersion'] || @driver.session_capabilities['platformVersion']
        p_version.split('.').map(&:to_i)
      end

      # Takes a png screenshot and saves to the target path.
      #
      # @param png_save_path [String] the full path to save the png
      # @return [File]
      #
      # @example
      #
      #   @core.screenshot '/tmp/hi.png' #=> nil
      #   # same as '@driver.save_screenshot png_save_path'
      #
      def screenshot(png_save_path)
        ::Appium::Logger.warn '[DEPRECATION] screenshot will be removed. Please use driver.save_screenshot instead.'
        @driver.save_screenshot png_save_path
      end

      private

      # @private
      def extend_for(device:, automation_name:)
        extend Appium::Core
        extend Appium::Core::Device

        case device
        when :android
          case automation_name
          when :espresso
            ::Appium::Core::Android::Espresso::Bridge.for(self)
          when :uiautomator2
            ::Appium::Core::Android::Uiautomator2::Bridge.for(self)
          else # default and UiAutomator
            ::Appium::Core::Android::Uiautomator1::Bridge.for(self)
          end
        when :ios, :tvos
          case automation_name
          when :xcuitest
            ::Appium::Core::Ios::Xcuitest::Bridge.for(self)
          else # default and UIAutomation
            ::Appium::Core::Ios::Uiautomation::Bridge.for(self)
          end
        when :mac
          # no Mac specific extentions
          ::Appium::Logger.debug('mac')
        when :windows
          # no windows specific extentions
          ::Appium::Logger.debug('windows')
        when :tizen
          # https://github.com/Samsung/appium-tizen-driver
          ::Appium::Logger.debug('tizen')
        else
          case automation_name
          when :youiengine
            # https://github.com/YOU-i-Labs/appium-youiengine-driver
            ::Appium::Logger.debug('YouiEngine')
          else
            ::Appium::Logger.warn("No matched driver by platformName: #{device} and automationName: #{automation_name}")
          end
        end

        self
      end

      # @private
      def validate_keys(opts)
        flatten_ops = flatten_hash_keys(opts)

        raise Error::NoCapabilityError unless opts.member?(:caps) || opts.member?(:desired_capabilities)

        if !opts.member?(:appium_lib) && flatten_ops.member?(:appium_lib)
          raise Error::CapabilityStructureError, 'Please check the value of appium_lib in the capability'
        end

        true
      end

      # @private
      def flatten_hash_keys(hash, flatten_keys_result = [])
        hash.each do |key, value|
          flatten_keys_result << key
          flatten_hash_keys(value, flatten_keys_result) if value.is_a?(Hash)
        end

        flatten_keys_result
      end

      # @private
      def get_caps(opts)
        Core::Base::Capabilities.create_capabilities(opts[:caps] || opts[:desired_capabilities] || {})
      end

      # @private
      def get_appium_lib_opts(opts)
        opts[:appium_lib] || {}
      end

      # @private
      # Path to the .apk, .app or .app.zip.
      # The path can be local, HTTP/S, Windows Share and other path like 'sauce-storage:'.
      # Use @caps[:app] without modifications if the path isn't HTTP/S or local path.
      def set_app_path
        return unless @caps && @caps[:app] && !@caps[:app].empty?
        return if @caps[:app] =~ URI::DEFAULT_PARSER.make_regexp

        app_path = File.expand_path(@caps[:app])
        @caps[:app] = if File.exist? app_path
                        app_path
                      else
                        ::Appium::Logger.warn("Use #{@caps[:app]} directly since #{app_path} does not exist.")
                        @caps[:app]
                      end
      end

      # @private
      # Below capabilities are set only for client side.
      def set_appium_lib_specific_values(appium_lib_opts)
        opts = Options.new appium_lib_opts

        @custom_url ||= opts.custom_url # Keep existence capability if it's already provided

        @default_wait = opts.default_wait

        @export_session = opts.export_session
        @export_session_path = opts.export_session_path

        @port = opts.port

        @wait_timeout  = opts.wait_timeout
        @wait_interval = opts.wait_interval

        @listener = opts.listener

        @direct_connect = opts.direct_connect
      end

      # @private
      def set_appium_device
        # https://code.google.com/p/selenium/source/browse/spec-draft.md?repo=mobile
        @device = @caps[:platformName]
        return @device unless @device

        @device = @device.is_a?(Symbol) ? @device.downcase : @device.downcase.strip.intern
      end

      # @private
      def set_automation_name
        @automation_name = @caps[:automationName] if @caps[:automationName]
        @automation_name = if @automation_name
                             @automation_name.is_a?(Symbol) ? @automation_name.downcase : @automation_name.downcase.strip.intern
                           end
      end

      # @private
      def set_automation_name_if_nil
        return unless @automation_name.nil?

        @automation_name = if @driver.capabilities['automationName']
                             @driver.capabilities['automationName'].downcase.strip.intern
                           end
      end

      # @private
      def write_session_id(session_id, export_path = '/tmp/appium_lib_session')
        export_path = export_path.tr('/', '\\') if ::Appium::Core::Base.platform.windows?
        File.write(export_path, session_id)
      rescue IOError => e
        ::Appium::Logger.warn e
        nil
      end
    end # class Driver
  end # module Core
end # module Appium
