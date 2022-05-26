module Shiva
  module Common
    module Act
      def self.call(controller, foe)
        proposed_action = controller.best_action(foe)
        # prevent followers from drive-by poaching
        return :noop if !Claim.mine? && !(Group.empty? || Group.leader?)
        Action.call(proposed_action, foe)
        sleep 0.1
        return proposed_action if proposed_action.is_a?(Symbol)
        proposed_action.to_sym
      end
    end
  end
end