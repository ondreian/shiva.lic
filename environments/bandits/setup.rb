module Shiva
  module Bandits
    class Setup < Stage
      
      def scripts
        %w(reaction effect-watcher lte)
      end

      def talk_to_guard
        Go2.advguard
        previous_state = checkbounty
        Bounty.ask_for_bounty
        wait_while {checkbounty.eql?(previous_state)}
      end

      def talk_to_task_master
        Go2.advguild
        previous_state = checkbounty
        Bounty.ask_for_bounty
        wait_while {checkbounty.eql?(previous_state)}
      end

      def krakens_fall_setup
        case Bounty.task.type
        when :succeeded
          self.turn_in_current_task
        when :bandit
          return
        when :get_bandits
          self.talk_to_guard
        when :report_to_guard
          self.talk_to_guard
          self.turn_in_current_task
        when :none
          if Effects::Cooldowns.active?("Next Bounty")
            Script.run("go2", Location.resting_room)
            wait_while("waiting on bounty timer...") {Effects::Cooldowns.active?("Next Bounty")}
          end
          self.talk_to_task_master
          self.talk_to_guard
        end
      end

      def turn_in_current_task
        if Mind.saturated?
          Script.run("go2", Location.resting_room)
          wait_while("waiting on absorption") {Mind.saturated?}
        end
        Go2.advguild
        Bounty.ask_for_bounty
        self.krakens_fall_setup
      end

      def deposit_silver
        Errand.run("bank") {fput "deposit all"}
      end

      def activate_group
        return unless Group.leader?
        return if Group.empty?
        Group.members.map(&:noun).map do |member|
          Cluster.cast(member, 
            channel: :script, 
            script:  :shiva,
            args:    %(--env=bandits),
          )
        end
      end

      def entry_point
        Bandits.find_entry_point(@env.area)
      end

      def apply(env)
        Char.arm
        Group.check
        return unless Group.empty? or Group.leader?
        
        return if Room.current.location.eql?(@env.area)
        self.krakens_fall_setup if Location.nearest_town =~ /Kraken's Fall/
        self.deposit_silver if percentencumbrance > 0
        fail "weird encumbrance" if percentencumbrance > 0
        wait_while("waiting on mana") {percentmana < 70}
        if Opts["task"]
          Script.run("go2", Location.resting_room)
          exit
        end

        @env.area = Bounty.task.area

        if Group.empty? or Group.leader?
          $bounty_cli.share
          self.entry_point.go2
          self.activate_group
        else
          id = self.entry_point
          wait_until("waiting for entry point at {id=%s, title=%s}" % [id, Room[id].title.first]) { 
            Room.current.id.eql?(id) }
        end
      end
    end
  end
end