require 'net/http'
require './lib/appium_lib_core'

module Script
  class CommandsChecker
    attr_reader :spec_commands

    # https://raw.githubusercontent.com/appium/appium-base-driver/master/lib/mjsonwp/routes.js?raw=1
    def get_mjsonwp_routes(to_path = './mjsonwp_routes.js')
      uri = URI 'https://raw.githubusercontent.com/appium/appium-base-driver/master/lib/mjsonwp/routes.js?raw=1'
      result = Net::HTTP.get uri

      File.delete to_path
      File.write to_path, result
    end

    def get_all_command_path(path)
      current_command = ''
      @spec_commands = File.read(path).lines.reduce({}) { |memo, line|
        new_memo = if line.match(/'\/wd\/hub\/.+'/)
                     current_command = gsub_set(line.slice(/'\/wd\/hub\/.+'/))
                     memo.merge(current_command => [])
                   elsif line.match(%r(GET:|POST:|DELETE:|PUT:))
                     memo[current_command] << line.slice(%r(GET:|POST:|DELETE:|PUT:)).chop.downcase.to_sym
                     memo
                   else
                     memo
                   end
        new_memo
      }
    end

    def convert_core_commands
      Appium::Core::Commands::COMMANDS_EXTEND_MJSONWP.reduce({}) do |memo, command|
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

    def all_diff_commands_oss
      core_commands = convert_core_commands
      new = {}
      @spec_commands.each_key do |key|
        if core_commands.has_key? key
          diff = @spec_commands[key] - core_commands[key]
          puts diff
          unless diff.empty?
            new[key] = diff
          end
        else
          new[key] = @spec_commands[key]
        end
      end

      white_list.each { |v| new.delete v }
      w3c_spec.each { |v| new.delete v }

      new
    end

    def diff_except_for_webdriver
      (@spec_commands - white_list) - Appium::Core::Commands::COMMANDS.map { |v| v[1][1] }
    end

    def diff_webdriver_oss
      (@spec_commands - white_list - w3c_spec) - Appium::Core::Base::Commands::OSS.map { |v| v[1][1] }
    end

    def all_diff_commands_w3c
      (@spec_commands - white_list - oss_spec) - Appium::Core::Commands::COMMANDS_EXTEND_W3C.map { |v| v[1][1] }
    end

    def diff_webdriver_w3c
      (@spec_commands - white_list - oss_spec) - Appium::Core::Base::Commands::W3C.map { |v| v[1][1] }
    end

    private

    def white_list
      %w(
        '/wd/hub/session'
        '/wd/hub/sessions'
      ).map { |v| gsub_set(v) }
    end

    # https://raw.githubusercontent.com/appium/appium-base-driver/master/lib/mjsonwp/routes.js
    def oss_spec
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

    def gsub_set(line)
      line
          &.gsub(/(\A'\/wd\/hub\/|'\z)/, '')
          &.sub(':sessionId', ':session_id')
          &.sub('element/:elementId', 'element/:id')
          &.sub(':windowhandle', ':window_handle')
          &.sub('equals/:otherId', 'equals/:other')
          &.sub('css/:propertyName', 'css/:property_name')
          &.sub('element/:id/pageIndex', 'element/:id/page_index')
    end
  end
end

c = Script::CommandsChecker.new
c.get_mjsonwp_routes
c.get_all_command_path './mjsonwp_routes.js'

# puts c.all_diff_commands_oss

require 'pry'
binding.pry
