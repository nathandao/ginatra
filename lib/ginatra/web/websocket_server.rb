module Ginatra
  class WebsocketServer
    attr_accessor :clients

    class << self
      def start
        @clients ||= []
        websocket_port = Ginatra::Env.websocket_port || 9290

        EM::WebSocket.start(:host => '0.0.0.0', :port => websocket_port) do |ws|

          ws.onopen do |handshake|
            ws.send "Connected"
            @clients << ws
          end

          ws.onmessage do |msg|
            @clients.each do |socket|
              if socket != ws
                socket.send msg
              end
            end
          end

          ws.onclose do
            ws.send "Closed."
            @clients.delete ws
            ws = nil
          end

          # hit Control + C to stop
          Signal.trap("INT")  { EventMachine.stop }
          Signal.trap("TERM") { EventMachine.stop }
        end
      end
    end
  end
end
