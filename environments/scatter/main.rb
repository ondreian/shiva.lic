module Shiva
  module Scatter
    class Main < Stage
      Danger = %w(crawler siphon master destroyer cerebralite doll)

      def foes
        return [] unless Claim.mine?
        Foes.reject {|foe| foe.noun.eql?("doll")}.sort_by do |foe|
          if foe.name =~ /grizzled|ancient/ or foe.noun.eql?("master")
            0
          elsif checkbounty.include?(foe.noun)
            1
          else
            2 + Danger.index(foe.noun) - foe.status.size
          end
        end
      end

      def foe
        if Claim.mine?
          self.foes.first
        else
          nil
        end
      end

      def act(env)
        foe = self.foe
        proposed_action = env.best_action(foe)
        Action.call proposed_action, foe
        sleep 0.1
        proposed_action.class.name.split("::").last.downcase.to_sym
      end

      def apply(env)
        before_dying { Script.kill("wander-scatter") }
        loop {
          wait_until {Claim.mine? or checkpcs.nil?}
          action = self.act(env)
          Log.out(action, label: %i(previous action))
          break if action.eql?(:rest)
        }
      end
    end
  end
end