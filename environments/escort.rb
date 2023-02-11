module Shiva
  Environment.define :escort do

    def self.setup
      return :noop
    end

    def self.main
      until GameObj.targets.empty?
        (proposed_action, foe) = self.best_action
        Action.call(proposed_action, foe)
        Log.out("proposed.action=%s foe=%s" % [proposed_action.to_sym, foe.name], label: %i(escort logic)) unless proposed_action.eql?(@previous_action)
        @previous_action = proposed_action
        sleep 0.1
      end
      
      return unless Claim.mine?
      search = self.action(:loot)
      search.apply
      sleep 0.1
      loot = self.action(:lootarea)
      loot.apply
    end

    def self.teardown
      :noop
    end
  end
end