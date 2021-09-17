module Shiva
  module Osa
    class Main < Stage
      def foes
        GameObj.targets.map {|f| Creature.new(f)}
      end

      def foe
        self.foes.sample
      end

      def act(env)
        foe = self.foe
        Action.call env.best_action(foe), foe
        sleep 0.1
      end

      def wait_for_boarding!
        return if Opts["skip-boarding"]
        wait_until {foe or XMLData.room_title.include?("Enemy Ship")}
      end

      def apply(env)
        loop {
          wait_for_boarding!
          self.act(env)
        }
      end
    end
  end
end