module Shiva
  module Sanctum
    class Main < Stage
      Danger = %w(shaper sidewinder sentinel fanatic lurk monstrosity)

      def foes
        return [] unless Claim.mine?
        Foes.sort_by do |foe|
          if foe.name =~ /grizzled|ancient/ or foe.noun.eql?("shaper")
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
        Action.call env.best_action(foe), foe
        sleep 0.1
      end

      def apply(env)
        loop {
          wait_until {Claim.mine?}
          self.act(env)
        }
      end
    end
  end
end