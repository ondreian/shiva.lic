module Shiva
  module Common
    module Act
      def self.call(controller, foe)
        proposed_action = controller.best_action(foe)
        Action.call(proposed_action, foe)
        sleep 0.1
        return proposed_action if proposed_action.is_a?(Symbol)
        proposed_action.class.name.split("::").last.downcase.to_sym
      end
    end
  end
end