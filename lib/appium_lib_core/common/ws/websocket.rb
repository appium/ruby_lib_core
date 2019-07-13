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

require 'faye/websocket'
require 'eventmachine'

module Appium
  module Core
    class WebSocket
      attr_reader :client, :endpoint

      # A websocket client based on Faye::WebSocket::Client .
      # Uses eventmachine to wait response from the peer. The eventmachine works on a thread. The thread will exit
      # with close method.
      #
      # @param [String] url URL to establish web socket connection. If the URL has no port, the client use:
      #                     +ws+: 80, +wss+: 443 ports.
      # @param [Array] protocols An array of strings representing acceptable subprotocols for use over the socket.
      #                          The driver will negotiate one of these to use via the Sec-WebSocket-Protocol header
      #                          if supported by the other peer. Default is nil.
      #                          The protocols is equal to https://github.com/faye/faye-websocket-ruby/ 's one for client.
      # @param [Hash] options Initialize options for Faye client. Read https://github.com/faye/faye-websocket-ruby#initialization-options
      #                       for more details. Default is +{}+.
      #
      # @example
      #     ws = WebSocket.new(url: "ws://#{host}:#{port}/ws/session/#{@session_id}/appium/device/logcat")
      #     ws.client #=> #<Faye::WebSocket::Client:.....> # An instance of Faye::WebSocket::Client
      #     ws.message 'some message' #=> nil. Send a message to the peer.
      #     ws.close #=> Kill the thread which run a eventmachine.
      #
      def initialize(url:, protocols: nil, options: {})
        @endpoint = url

        @ws_thread = Thread.new do
          EM.run do
            @client ||= ::Faye::WebSocket::Client.new(url, protocols, options)

            @client.on :open do |_open|
              handle_open
            end

            @client.on :message do |message|
              handle_message_data(message.data)
            end

            @client.on :error do |_error|
              handle_error
            end

            @client.on :close do |close|
              handle_close(close.code, close.reason)
            end
          end
        end
      end

      # Client

      #
      # Sends a ping frame with an optional message and fires the callback when a matching pong is received.
      #
      # @param [String] message A message to send ping.
      # @param [Block] callback
      #
      # @example
      #     ws = WebSocket.new(url: "ws://#{host}:#{port}/ws/session/#{@session_id}/appium/device/logcat")
      #     ws.ping 'message'
      #
      def ping(message, &callback)
        @client.ping message, &callback
      end

      # Accepts either a String or an Array of byte-sized integers and sends a text or binary message over the connection
      # to the other peer; binary data must be encoded as an Array.
      #
      # @param [String|Array] message A message to send a text or binary message over the connection
      #
      # @example
      #     ws = WebSocket.new(url: "ws://#{host}:#{port}/ws/session/#{@session_id}/appium/device/logcat")
      #     ws.send 'happy testing'
      #
      def send(message)
        @client.send message
      end

      # Closes the connection, sending the given status code and reason text, both of which are optional.
      #
      # @param [Integer] code A status code to send to the peer with close signal. Default is nil.
      # @param [String] reason A reason to send to the peer with close signal. Default is 'close from ruby_lib_core'.
      #
      # @example
      #     ws = WebSocket.new(url: "ws://#{host}:#{port}/ws/session/#{@session_id}/appium/device/logcat")
      #     ws.close reason: 'a something special reason'
      #
      def close(code: nil, reason: 'close from ruby_lib_core')
        if @client.nil?
          ::Appium::Logger.warn 'Websocket was closed'
        else
          @client.close code, reason
        end
        @ws_thread.exit
      end

      # Response from server

      #
      # Fires when the socket connection is established. Event has no attributes.
      #
      # Default is just put a debug message.
      #
      def handle_open
        ::Appium::Logger.debug %W(#{self.class} :open)
      end

      # Standard out by default
      # In general, users should customise only message_data

      #
      # Fires when the socket receives a message. The message gas one +data+ attribute and this method can handle the data.
      # The data is either a String (for text frames) or an Array of byte-sized integers (for binary frames).
      #
      # Default is just put a debug message and puts the result on standard out.
      # In general, users should override this handler to handle messages from the peer.
      #
      def handle_message_data(data)
        ::Appium::Logger.debug %W(#{self.class} :message #{data})
        $stdout << "#{data}\n"
      end

      #
      # Fires when there is a protocol error due to bad data sent by the other peer.
      # This event is purely informational, you do not need to implement error recovery.
      #
      # Default is just put a error message.
      #
      def handle_error
        ::Appium::Logger.error %W(#{self.class} :error)
      end

      #
      # Fires when either the client or the server closes the connection. The method gets +code+ and +reason+ attributes.
      # They expose the status code and message sent by the peer that closed the connection.
      #
      # Default is just put a error message.
      # The methods also clear +client+ instance and stop the eventmachine which is called in initialising this class.
      #
      def handle_close(code, reason)
        ::Appium::Logger.debug %W(#{self.class} :close #{code} #{reason})
        @client = nil
        EM.stop
      end
    end # module WebSocket
  end # module Core
end # module Appium
