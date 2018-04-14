require 'faye/websocket'
require 'eventmachine'

module Appium
  module Core
    class WebSocket
      attr_reader :client

      def initialize(url:, protocols: nil, options: {})
        @client ||= Faye::WebSocket::Client.new(url, protocols, options)

        EM.run {
          @client.onopen do |_open|
            p [:open]
          end

          @client.onmessage do |message|
            p [:message, message.data]
          end

          @client.onerror do |_error|
            p [:error]
          end

          @client.onclose do |close|
            p [:close, close.code, close.reason]
            @client = nil
          end
        }
      end

      def ping(message, &callback)
        @client.ping message, &callback
      end

      def send(message)
        @client.send message
      end

      def close(code: nil, reason: 'close from ruby_lib_core')
        @client.close code, reason
        EM.stop
      end
    end # module WebSocket
  end # module Core
end # module Appium


