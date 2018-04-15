require 'faye/websocket'
require 'eventmachine'

module Appium
  module Core
    class WebSocket
      attr_reader :client, :endpoint

      # ws://%s:%s/ws/session/%s/appium/device/logcat
      # Need session id
      def initialize(url: "ws://127.0.0.1:#{::Appium::Core::WebSocket::DEFAULT_APPIUM_PORT}", protocols: nil, options: {})
        @endpoint = url

        @ws_thread = Thread.new do
          EM.run do
            @client ||= ::Faye::WebSocket::Client.new(url, protocols, options)

            @client.on :open do |_open|
              response_open
            end

            @client.on :message do |message|
              response_message_data(message.data)
            end

            @client.on :error do |_error|
              response_error
            end

            @client.on :close do |close|
              response_close(close.code, close.reason)
            end
          end
        end
      end

      def ping(message, &callback)
        @client.ping message, &callback
      end

      def send(message)
        @client.send message
      end

      def close(code: nil, reason: 'close from ruby_lib_core')
        @client.close code, reason
        @ws_thread.exit
      end

      private

      # Response from server

      def response_open
        Logger.warn %w(:open)
      end

      def response_message_data(data)
        Logger.warn %W(:message #{data})
      end

      def response_error
        Logger.error %w(:error)
      end

      def response_close(code, reason)
        Logger.warn %W(:close #{code} #{reason})
        @client = nil
        EM.stop
      end
    end # module WebSocket
  end # module Core
end # module Appium
