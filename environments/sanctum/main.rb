module Shiva
  module Sanctum
    class Main < Stage
      Danger = %w(shaper sentinel fanatic lurk monstrosity)

      def foes
        Foes.sort_by do |foe|
          if foe.name =~ /grizzled|ancient/ or checkbounty.include?(foe.noun)
            0
          else
            1 + Danger.index(foe.noun) - foe.status.size
          end
        end
      end

      def foe
        self.foes.first
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