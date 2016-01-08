require 'eventmachine'

module Ginatra
  class WebsocketServer
    attr_accessor :channel, :scheduler

    class << self
      def start
        websocket_port = Ginatra::Env.websocket_port || 9290

        @channel = EM::Channel.new

        EM::WebSocket.start(:host => '0.0.0.0', :port => websocket_port) do |ws|
          ws.onopen do |handshake|
            sid = @channel.subscribe { |msg| ws.send msg }

            ws.onclose do
              @channel.unsubscribe(sid)
              ws = nil
            end
          end

          # hit Control + C to stop
          Signal.trap("INT")  { EventMachine.stop }
          Signal.trap("TERM") { EventMachine.stop }
        end

        Ginatra::Stat.start_repo_streams(@channel, Ginatra::Config.update_interval)
      end
    end
  end
end
