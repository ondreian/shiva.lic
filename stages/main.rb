module Shiva
  class Main
    attr_reader :env

    def initialize(env)
      @env = env
    end

    def make_decision
      (proposed_action, foe) = self.env.best_action
      # prevent followers from drive-by poaching
      return :noop if !Claim.mine? && !(Group.empty? || Group.leader?)
      Action.call(proposed_action, foe)
      sleep 0.1
      return proposed_action if proposed_action.is_a?(Symbol)
      proposed_action.to_sym
    end

    def apply()
      env.reset_start_time!

      loop {
        action = self.make_decision()
        #Log.out(action, label: %i(previous action)) unless action.eql?(@previous_action)
        @previous_action = action
        break if @previous_action.eql?(:rest)
        sleep 0.1
      }
    end
  end
end