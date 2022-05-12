module Shiva
  module Common
    module Act
      def self.call(env, foe)
        proposed_action = env.best_action(foe)
        Action.call(proposed_action, foe)
        sleep 0.1
        proposed_action.class.name.split("::").last.downcase.to_sym
      end
    end
  end
end