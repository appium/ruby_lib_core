require 'test_helper'
require 'webmock/minitest'

class AppiumLibCoreTest
  class WebSocketTest < Minitest::Test
    def test_connect_websocket
      ws = ::Appium::Core::WebSocket.new(url: 'ws://localhost:9292')
      assert_nil ws.client
    end
  end
end
