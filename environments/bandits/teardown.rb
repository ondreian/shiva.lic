module Shiva
  module Bandits
    class Teardown < Stage
      def turn_in!
        Script.run "go2", "advguard"
        Bounty.ask_for_bounty
        $bounty_cli.ask if Group.leader?
        if Mind.saturated?
          Script.run "go2", Location.resting_room
          wait_while("waiting on saturation") {Mind.saturated?}
        end
        Go2.advguild
        Bounty.ask_for_bounty
        $bounty_cli.ask if Group.leader?
        Go2.bank
        fput "deposit all"
        $cluster_cli.run("deposit")
        ttl = Time.now + 5
        wait_until("waiting on deposits...") {Time.now>ttl}
      end

      def heal!
        return if Char.total_wound_severity == 0
        Script.run "go2", Location.resting_room
        Team.request_healing
        wait_while("waiting on healing...") {Char.total_wound_severity > 0}
      end

      def apply(env)
        exit unless Group.leader? or Group.empty?
        Char.unhide if Char.hidden?
        wait_until {Room.current.id.eql?(Location.resting_room) } unless Group.leader? or Group.empty?
        self.heal!
        self.turn_in!
        Script.run "go2", Location.resting_room
        exit
      end
    end
  end
end