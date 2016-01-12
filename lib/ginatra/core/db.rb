require 'neo4j-core'

module Ginatra
  class Db
    class << self
      def session
        Neo4j::Session.open(:server_db, 'http://localhost:7474',
                            basic_auth: {
                              username: 'neo4j',
                              password: 'admin'
                            },
                            initialize: {
                              request: {
                                open_timeout: 2,   # opening a connection
                                timeout: 6000         # waiting for response
                              }
                            })
      end
    end
  end
end
