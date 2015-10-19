require 'rufus-scheduler'
require 'yajl/json_gem'

module Ginatra
  class WebsocketServer
    attr_accessor :channel, :scheduler

    class << self
      def start
        websocket_port = Ginatra::Env.websocket_port || 9290

        @channel = EM::Channel.new
        @scheduler = Rufus::Scheduler.new

        update_interval = Ginatra::Config.update_interval || "60s"

        @scheduler.every update_interval do
          updated_repos = Ginatra::Stat.list_updated_repos
          unless updated_repos == ""
            sid = @channel.subscribe { |msg| p [Time.now, "updated repos", updated_repos] }
            @channel.push updated_repos
            @channel.unsubscribe(sid)
          end
        end

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
      end
    end
  end
end
