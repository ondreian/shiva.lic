module Shiva
  module Sanctum
    class Main < Stage
      Danger = %w(shaper sidewinder sentinel fanatic lurk monstrosity)

      def foes
        return [] unless Claim.mine?
        Foes.select do |foe| Danger.include?(foe.noun) end.sort_by do |foe|
          if foe.name =~ /grizzled|ancient/ or foe.noun.eql?("shaper")
            0
          elsif checkbounty.include?(foe.noun)
            1
          else
            2 + Danger.index(foe.noun) - foe.status.size
          end
        end.reject {|foe| foe.noun.eql?("monstrosity") or foe.noun.eql?("arm")}
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
        return proposed_action if proposed_action.eql?(:noop)
        proposed_action.class.name.split("::").last.downcase.to_sym
      end

      def apply(env)
        loop {
          wait_until {Claim.mine? or checkpcs.nil?}
          action = self.act(env)
          #Log.out(action, label: %i(previous action)) 
          break if action.eql?(:rest)
        }
      end
    end
  end
end