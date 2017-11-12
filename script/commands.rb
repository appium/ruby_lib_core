require 'net/http'
require './lib/appium_lib_core'

module Script
  class CommandsChecker
    attr_reader :spec_commands
    attr_reader :implemented_mjsonwp_commands, :implemented_w3c_commands, :implemented_core_commands
    attr_reader :webdriver_oss_commands, :webdriver_w3c_commands

    # Set commands implemented in this core library.
    #
    # - implemented_mjsonwp_commands:  All commands include ::Selenium::WebDriver::Remote::OSS::Bridge::COMMANDS
    # - implemented_w3c_commands:  All commands include ::Selenium::WebDriver::Remote::W3C::Bridge::COMMANDS
    # - implemented_core_commands:  All commands except for selenium-webdriver's commands
    # - webdriver_oss_commands: ::Selenium::WebDriver::Remote::OSS::Bridge::COMMANDS
    # - webdriver_w3c_commands: ::Selenium::WebDriver::Remote::W3C::Bridge::COMMANDS
    #
    def initialize
      @implemented_mjsonwp_commands = convert_driver_commands Appium::Core::Commands::COMMANDS_EXTEND_MJSONWP
      @implemented_w3c_commands = convert_driver_commands Appium::Core::Commands::COMMANDS_EXTEND_W3C
      @implemented_core_commands = convert_driver_commands Appium::Core::Commands::COMMANDS

      @webdriver_oss_commands = convert_driver_commands Appium::Core::Base::Commands::OSS
      @webdriver_w3c_commands = convert_driver_commands Appium::Core::Base::Commands::W3C
    end

    # Get the bellow url's file.
    # https://raw.githubusercontent.com/appium/appium-base-driver/master/lib/mjsonwp/routes.js?raw=1
    #
    # @param [String] to_path: A file path to routes.js
    # @return [String] The file path in which has saved `routes.js`.
    #
    def get_mjsonwp_routes(to_path = './mjsonwp_routes.js')
      uri = URI 'https://raw.githubusercontent.com/appium/appium-base-driver/master/lib/mjsonwp/routes.js?raw=1'
      result = Net::HTTP.get uri

      File.delete to_path
      File.write to_path, result
      to_path
    end

    # Read routes.js and set the values in @spec_commands
    #
    # @param [String] path: A file path to routes.js
    # @return [Hash] @spec_commands
    #
    def get_all_command_path(path = './mjsonwp_routes.js')
      raise "No file in #{path}" unless File.exist? path

      current_command = ''
      @spec_commands = File.read(path).lines.reduce({}) do |memo, line|
        new_memo = if line =~ %r('\/wd\/hub\/.+')
                     current_command = gsub_set(line.slice(%r('\/wd\/hub\/.+')))
                     memo.merge(current_command => [])
                   elsif line =~ /GET:|POST:|DELETE:|PUT:/
                     memo[current_command] << line.slice(/GET:|POST:|DELETE:|PUT:/).chop.downcase.to_sym
                     memo
                   else
                     memo
                   end
        new_memo
      end
    end

    # All commands which haven't been implemented in ruby core library yet.
    # @return [Hash]
    #
    def all_diff_commands_mjsonwp
      new = compare_commands(@spec_commands, @implemented_mjsonwp_commands)

      white_list.each { |v| new.delete v }
      w3c_spec.each { |v| new.delete v }

      new
    end

    # All commands which haven't been implemented in ruby core library yet.
    # @return [Hash]
    #
    def all_diff_commands_w3c
      new = compare_commands(@spec_commands, @implemented_w3c_commands)

      white_list.each { |v| new.delete v }
      mjsonwp_spec.each { |v| new.delete v }

      new
    end

    # Commands, only this core library, which haven't been implemented in ruby core library yet.
    # @return [Hash]
    #
    def diff_except_for_webdriver
      new = compare_commands(@spec_commands, @implemented_core_commands)
      white_list.each { |v| new.delete v }
      new
    end

    def diff_webdriver_oss
      new = compare_commands(@spec_commands, @webdriver_oss_commands)
      white_list.each { |v| new.delete v }
      w3c_spec.each { |v| new.delete v }
      new
    end

    def diff_webdriver_w3c
      new = compare_commands(@spec_commands, @webdriver_w3c_commands)
      white_list.each { |v| new.delete v }
      mjsonwp_spec.each { |v| new.delete v }
      new
    end

    def compare_commands(command1, with_command2)
      return {} if command1.nil?
      return command1 if with_command2.nil?

      new = {}
      command1.each_key do |key|
        if with_command2.key? key
          diff = command1[key] - with_command2[key]
          new[key] = diff unless diff.empty?
        else
          new[key] = command1[key]
        end
      end
      new
    end

    private

    # rubocop:disable Lint/PercentStringArray
    def white_list
      %w(
        '/wd/hub/session'
        '/wd/hub/sessions'
      ).map { |v| gsub_set(v) }
    end

    # https://raw.githubusercontent.com/appium/appium-base-driver/master/lib/mjsonwp/routes.js
    def mjsonwp_spec
      %w(
        '/wd/hub/session/:sessionId/alert_text'
        '/wd/hub/session/:sessionId/accept_alert'
        '/wd/hub/session/:sessionId/dismiss_alert'
      ).map { |v| gsub_set(v) }
    end

    def w3c_spec
      %w(
        '/wd/hub/session/:sessionId/alert/text'
        '/wd/hub/session/:sessionId/alert/accept'
        '/wd/hub/session/:sessionId/alert/dismiss'
        '/wd/hub/session/:sessionId/element/:elementId/rect'
      ).map { |v| gsub_set(v) }
    end
    # rubocop:enable Lint/PercentStringArray

    def gsub_set(line)
      return nil if line.gsub(%r((\A'\/wd\/hub\/|'\z)), '').nil?

      line.gsub(%r((\A'\/wd\/hub\/|'\z)), '')
          .sub(':sessionId', ':session_id')
          .sub('element/:elementId', 'element/:id')
          .sub(':windowhandle', ':window_handle')
          .sub('equals/:otherId', 'equals/:other')
          .sub('css/:propertyName', 'css/:property_name')
          .sub('element/:id/pageIndex', 'element/:id/page_index')
    end

    def convert_driver_commands(from)
      from.each_with_object({}) do |command, memo|
        method = command[1][0]
        key = command[1][1]

        if memo[key]
          memo[key] << method
        else
          memo[key] = [method]
        end

        memo
      end
    end
  end
end
