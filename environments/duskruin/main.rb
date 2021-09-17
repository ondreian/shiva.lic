module Shiva
  module Duskruin
    Rooms = OpenStruct.new(
        combat:   [24550],
        entrance: [23780],
        exit:     [23798],
        team:     [26387],
        solo:     [23780],
      )

    class Main < Stage
      Round = /An announcer shouts, "Round (?<round>\d+), send in/

      attr_accessor :round

      def initialize()
        @round = 1
        DownstreamHook.add("shiva/round-count", -> line {
          begin
            self.set_round(line) if line =~ Round
          rescue => exception
            Log.out(exception)
          ensure
            return line
          end
        })
      end

      def set_round(incoming)
        @round = incoming.match(Round)[:round].to_i
      end

      def done?
        return true if Duskruin::Rooms.exit.include?(Room.current.id)
        self.round.eql?(25) and Foes.empty? and not Opts["endless"]
      end

      def round
        @round
      end

      def alert_endless
        _respond %[<b>***\nENDLESS MODE\n***</b>]
      end

      def foe
        Foes.sample
      end

      def apply(env)
        self.alert_endless if Opts["endless"]
        wait_while {Foes.empty?}
        until self.done? do 
          foe = self.foe
          Action.call env.best_action(foe), foe
          sleep 0.1
        end
      end
    end
  end
end