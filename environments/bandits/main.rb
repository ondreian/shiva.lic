module Shiva
  module Bandits
    class Main < Stage
      attr_accessor :area

      def foes
        Foes.select {|foe| foe.tags.include?(:bandit)}
      end

      def foe
        return nil unless Claim.mine? 
        self.foes.sample
      end

      def act(foe)
        action = @env.best_action(foe)
        Action.call(action, foe)
        return action
      end

      def group_members_need_more?
        members = Group.members.map(&:name)
        tasks = Cluster.map(members, channel: :bounty)
        #Log.out(tasks, label: %i(group sitrep))
        # retry on next go
        return true if tasks.any? {|task| task.is_a?(Exception)}
        return false if tasks.all? {|task| task.type.eql?(:report_to_guard)}
        return tasks.any? do |task| task.area.include?(Room.current.location) end
      end

      def needs_more?
        return true if Bounty.type.eql?(:bandits) or Bounty.type.eql?(:help_bandits)
        return true if Group.size > 0 and not Group.leader?
        return true if Group.size > 0 and self.group_members_need_more?
        return true unless Group.members.map(&:status).compact.empty?
        return true unless @env.foes.empty?
        # don't wander endlessly
        return false if @env.best_action(self.foe).is_a?(Shiva::Wander)
        return true unless @env.best_action(self.foe).eql?(:noop)
        return true unless Creatures.dead.empty?
        false
      end

      def kill_lte!
        return unless Script.running?("lte")
        Script.kill("lte") if Bounty.task.number < 5
      end

      def apply(env)
        while self.needs_more?
          self.kill_lte!
          wait_while("waiting on noop...") {@env.best_action(self.foe).eql?(:noop)}
          self.act(self.foe)
          sleep 0.1
        end
        Char.unhide
      end
    end
  end
end