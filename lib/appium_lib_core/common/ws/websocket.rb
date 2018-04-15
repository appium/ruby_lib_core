require 'faye/websocket'
require 'eventmachine'

module Appium
  module Core
    class WebSocket
      attr_reader :ws_client, :endpoint

      # @example
      #     @ws_client = WebSocket.new(url: "ws://#{host}:#{port}/ws/session/#{@session_id}/appium/device/logcat")
      #     @ws_client.close
      #
      def initialize(url:, protocols: nil, options: {})
        @endpoint = url

        @ws_thread = Thread.new do
          EM.run do
            @ws_client ||= ::Faye::WebSocket::Client.new(url, protocols, options)

            @ws_client.on :open do |_open|
              handle_open
            end

            @ws_client.on :message do |message|
              handle_message_data(message.data)
            end

            @ws_client.on :error do |_error|
              handle_error
            end

            @ws_client.on :close do |close|
              handle_close(close.code, close.reason)
            end
          end
        end
      end

      # Client

      def ping(message, &callback)
        @ws_client.ping message, &callback
      end

      def send(message)
        @ws_client.send message
      end

      def close(code: nil, reason: 'close from ruby_lib_core')
        if @ws_client.nil?
          ::Appium::Logger.warn 'Websocket was closed'
        else
          @ws_client.close code, reason
        end
        @ws_thread.exit
      end

      # Response from server

      def handle_open
        ::Appium::Logger.debug %W(#{self.class} :open)
      end

      # Standard out by default
      # In general, users should customise only message_data
      def handle_message_data(data)
        ::Appium::Logger.debug %W(#{self.class} :message #{data})
        $stdout << "#{data}\n"
      end

      def handle_error
        ::Appium::Logger.error %W(#{self.class} :error)
      end

      def handle_close(code, reason)
        ::Appium::Logger.debug %W(#{self.class} :close #{code} #{reason})
        @ws_client = nil
        EM.stop
      end
    end # module WebSocket
  end # module Core
end # module Appium
