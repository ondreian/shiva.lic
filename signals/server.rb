require 'drb/drb'

module Signals
  class Server
    attr_reader :sock

    def initialize()
      loop do
        Thread.start(server.accept) do |conn|
          while incoming = conn.gets
            break if incoming.downcase =~ /^quit$/
            begin
              self.process(conn, JSON.parse(incoming))
            rescue => exception
              Log.out(exception.message)
            end
          end
          conn.puts "bye!"
          conn.close
        end
      end
    end

    def process(conn, incoming)
      case kind= incoming[:kind].downcase.to_sym
      when :health
        #conn.puts({
      else
        conn.puts({err: "unknown kind: %s" % kind}.to_json)
      end
    end
  end
end