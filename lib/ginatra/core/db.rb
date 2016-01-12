require 'neo4j-core'

module Ginatra
  class Db
    class << self
      def session
        # logger = Ginatra::Log.new().logger
        # logger.info("Opening new neo4j session")
        db_info = Ginatra::Config.neo4j
        Neo4j::Session.open(:server_db, db_info[:path],
                            basic_auth: {
                              username: db_info[:username],
                              password: db_info[:password]
                            },
                            initialize: {
                              request: {
                                open_timeout: db_info[:open_timeout],
                                timeout: db_info[:timeout]
                              }
                            })
      end
    end
  end
end
