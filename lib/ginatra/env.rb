module Ginatra
  class Env
    class << self
      attr_accessor :root, :data, :port, :websocket_port
    end
  end
end
