require 'test_helper'
require './script/commands'

class ScriptTest
  class CommandsCheckerTest < Minitest::Test
    def setup
      @c = Script::CommandsChecker.new

    end

    def test_get_all_command_path
      @c.get_all_command_path './test/unit/script/test_routes.js'
      assert_equal 143, @c.spec_commands.length
      assert_equal ['status', [:get]], @c.spec_commands.first
      assert_equal [:get, :post, :delete], @c.spec_commands['session/:session_id/cookie']

      assert_equal [:get], @c.spec_commands['session/:session_id/element/:id']
      assert_equal [:get, :post], @c.spec_commands['session/:session_id/window/:window_handle/size']
      assert_equal [:get], @c.spec_commands['session/:session_id/element/:id/equals/:other']
      assert_equal [:get], @c.spec_commands['session/:session_id/element/:id/css/:property_name']
      assert_equal [:get], @c.spec_commands['session/:session_id/element/:id/page_index']
    end

    # depends on webdriver-version... (number of commands)
    def test_appium_commands
      assert_equal 127, @c.implemented_mjsonwp_commands.length
      assert_equal ['session/:session_id/contexts', [:get]], @c.implemented_mjsonwp_commands.first
      assert_equal [:get, :post], @c.implemented_mjsonwp_commands['session/:session_id/alert_text']

      assert_equal 88, @c.implemented_w3c_commands.length
      assert_equal ['session/:session_id/contexts', [:get]], @c.implemented_w3c_commands.first
      assert_equal [:get, :post], @c.implemented_w3c_commands['session/:session_id/alert/text']

      assert_equal 42, @c.implemented_core_commands.length
      assert_equal ['session/:session_id/contexts', [:get]], @c.implemented_core_commands.first
      assert_equal [:post], @c.implemented_core_commands['session/:session_id/appium/device/pull_folder']

      assert_equal 86, @c.webdriver_oss_commands.length
      assert_equal ['session/:session_id', [:get, :delete]], @c.webdriver_oss_commands.first
      assert_equal [:get, :post], @c.webdriver_oss_commands['session/:session_id/alert_text']

      assert_equal 46, @c.webdriver_w3c_commands.length
      assert_equal ['session', [:post]], @c.webdriver_w3c_commands.first
      assert_equal [:get, :post], @c.webdriver_w3c_commands['session/:session_id/alert/text']
    end

    def test_compare_commands_command1_is_bigger
      command1 = { 'session/:session_id/contexts' => [:get] }
      command2 = { 'session/:session_id/contexts' => [:get, :post] }

      assert_equal({}, @c.compare_commands(command1, command2))
    end

    def test_compare_commands_command2_lack_some_commands
      command1 = { 'session/:session_id/contexts' => [:get, :post] }
      command2 = { 'session/:session_id/contexts' => [:get] }

      assert_equal({ 'session/:session_id/contexts' => [:post] }, @c.compare_commands(command1, command2))
    end

    def test_can_call_diff_methods
      assert_equal({}, @c.all_diff_commands_mjsonwp)
      assert_equal({}, @c.all_diff_commands_w3c)
      assert_equal({}, @c.diff_except_for_webdriver)
      assert_equal({}, @c.diff_webdriver_oss)
      assert_equal({}, @c.diff_webdriver_w3c)
    end
  end
end
