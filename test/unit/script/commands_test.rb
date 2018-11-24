require 'test_helper'
require './script/commands'

class ScriptTest
  class CommandsCheckerTest < Minitest::Test
    def setup
      @c = Script::CommandsChecker.new
    end

    def test_get_all_command_path
      @c.get_all_command_path AppiumLibCoreTest.path_of('test/unit/script/test_routes.js')
      assert_equal 143, @c.spec_commands.length
      assert_equal ['status', [:get]], @c.spec_commands.first
      assert_equal %i(get post delete), @c.spec_commands['session/:session_id/cookie']

      assert_equal [:get], @c.spec_commands['session/:session_id/element/:id']
      assert_equal %i(get post), @c.spec_commands['session/:session_id/window/:window_handle/size']
      assert_equal [:get], @c.spec_commands['session/:session_id/element/:id/equals/:other']
      assert_equal [:get], @c.spec_commands['session/:session_id/element/:id/css/:property_name']
      assert_equal [:get], @c.spec_commands['session/:session_id/element/:id/page_index']
    end

    # depends on webdriver-version... (number of commands)
    def test_implemented_mjsonwp_commands
      assert_equal 146, @c.implemented_mjsonwp_commands.length
      assert_equal ['session/:session_id/contexts', [:get]], @c.implemented_mjsonwp_commands.first

      # pick up an arbitrary command
      assert_equal %i(get post), @c.implemented_mjsonwp_commands['session/:session_id/alert_text']
    end

    def test_implemented_w3c_commands
      assert_equal 119, @c.implemented_w3c_commands.length
      assert_equal ['session/:session_id/contexts', [:get]], @c.implemented_w3c_commands.first

      # pick up an arbitrary command
      assert_equal %i(get post), @c.implemented_w3c_commands['session/:session_id/alert/text']
    end

    def test_implemented_core_commands
      assert_equal 60, @c.implemented_core_commands.length
      assert_equal ['session/:session_id/contexts', [:get]], @c.implemented_core_commands.first

      # pick up an arbitrary command
      assert_equal [:post], @c.implemented_core_commands['session/:session_id/appium/device/pull_folder']
    end

    def test_webdriver_oss_commands
      assert_equal 86, @c.webdriver_oss_commands.length
      assert_equal ['session/:session_id', %i(get delete)], @c.webdriver_oss_commands.first

      # pick up an arbitrary command
      assert_equal %i(get post), @c.webdriver_oss_commands['session/:session_id/alert_text']
    end

    def test_webdriver_w3c_commands
      assert_equal 47, @c.webdriver_w3c_commands.length
      assert_equal ['session', [:post]], @c.webdriver_w3c_commands.first

      # pick up an arbitrary command
      assert_equal %i(get post), @c.webdriver_w3c_commands['session/:session_id/alert/text']
    end

    def test_compare_commands_command1_is_bigger
      command1 = { 'session/:session_id/contexts' => [:get] }
      command2 = { 'session/:session_id/contexts' => %i(get post) }

      assert_equal({}, @c.compare_commands(command1, command2))
    end

    def test_compare_commands_command2_lack_some_commands
      command1 = { 'session/:session_id/contexts' => %i(get post) }
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
