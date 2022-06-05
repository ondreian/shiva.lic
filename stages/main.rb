module Shiva
  class Main
    attr_reader :controller, :env

    def initialize(controller)
      @controller = controller
      @env        = controller.env
    end

    def call(controller, foe)
      proposed_action = controller.best_action(foe)
      # prevent followers from drive-by poaching
      return :noop if !Claim.mine? && !(Group.empty? || Group.leader?)
      Action.call(proposed_action, foe)
      sleep 0.1
      return proposed_action if proposed_action.is_a?(Symbol)
      proposed_action.to_sym
    end

    def apply()
      controller.reset_start_time!

      loop {
        action = self.call(self.controller, self.env.foe)
        Log.out(action, label: %i(previous action)) unless action.eql?(@previous_action)
        @previous_action = action
        break if @previous_action.eql?(:rest)
        sleep 0.1
      }
    end
  end
end