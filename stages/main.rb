module Shiva
  class Main
    attr_reader :controller, :env

    def initialize(controller)
      @controller = controller
      @env        = controller.env
    end

    def apply()
      controller.reset_start_time!

      loop {
        wait_until {Claim.mine? or checkpcs.nil?}
        action = Common::Act.call(self.controller, self.env.foe)
        Log.out(action, label: %i(previous action)) unless action.eql?(@previous_action)
        @previous_action = action
        break if @previous_action.eql?(:rest)
      }
    end
  end
end