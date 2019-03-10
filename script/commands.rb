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
      @spec_commands = nil

      @implemented_mjsonwp_commands = convert_driver_commands Appium::Core::Commands::MJSONWP::COMMANDS
      @implemented_w3c_commands = convert_driver_commands Appium::Core::Commands::W3C::COMMANDS
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
      uri = URI 'https://raw.githubusercontent.com/appium/appium-base-driver/master/lib/protocol/routes.js?raw=1'
      result = Net::HTTP.get uri

      File.delete to_path if File.exist? to_path
      File.write to_path, result
      to_path
    end

    # @private
    HTTP_METHOD_MATCH = /GET:|POST:|DELETE:|PUT:|PATCH:/.freeze
    # @private
    WD_HUB_PREFIX_MATCH = "'/wd/hub/"

    # Read routes.js and set the values in @spec_commands
    #
    # @param [String] path: A file path to routes.js
    # @return [Hash] @spec_commands
    #
    def get_all_command_path(path = './mjsonwp_routes.js')
      raise "No file in #{path}" unless File.exist? path

      current_command = ''
      @spec_commands = File.read(path).lines.each_with_object({}) do |line, memo|
        if line =~ /#{WD_HUB_PREFIX_MATCH}.+'/
          current_command = gsub_set(line.slice(/#{WD_HUB_PREFIX_MATCH}.+'/))
          memo[current_command] = []
        elsif line =~ HTTP_METHOD_MATCH
          memo[current_command] << line.slice(HTTP_METHOD_MATCH).chop.downcase.to_sym
        end
        memo
      end
    end

    # All commands which haven't been implemented in ruby core library yet.
    # @return [Hash]
    #
    def all_diff_commands_mjsonwp
      result = compare_commands(@spec_commands, @implemented_mjsonwp_commands)

      white_list.each { |v| result.delete v }
      w3c_spec.each { |v| result.delete v }

      result
    end

    # All commands which haven't been implemented in ruby core library yet.
    # @return [Hash]
    #
    def all_diff_commands_w3c
      result = compare_commands(@spec_commands, @implemented_w3c_commands)
      white_list.each { |v| result.delete v }
      mjsonwp_spec.each { |v| result.delete v }
      result
    end

    # Commands, only this core library, which haven't been implemented in ruby core library yet.
    # @return [Hash]
    #
    def diff_except_for_webdriver
      result = compare_commands(@spec_commands, @implemented_core_commands)
      white_list.each { |v| result.delete v }
      result
    end

    def diff_webdriver_oss
      result = compare_commands(@spec_commands, @webdriver_oss_commands)
      white_list.each { |v| result.delete v }
      w3c_spec.each { |v| result.delete v }
      result
    end

    def diff_webdriver_w3c
      result = compare_commands(@spec_commands, @webdriver_w3c_commands)
      white_list.each { |v| result.delete v }
      mjsonwp_spec.each { |v| result.delete v }
      result
    end

    def compare_commands(command1, with_command2)
      return {} if command1.nil?
      return command1 if with_command2.nil?

      result = {}
      command1.each_key do |key|
        if with_command2.key? key
          diff = command1[key] - with_command2[key]
          result[key] = diff unless diff.empty?
        else
          result[key] = command1[key]
        end
      end
      result
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
      return nil if line.gsub(/(\A#{WD_HUB_PREFIX_MATCH}|'\z)/, '').nil?

      line.gsub(/(\A#{WD_HUB_PREFIX_MATCH}|'\z)/, '')
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
