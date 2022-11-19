module Shiva
  Environment.define :bandits do

    @scripts = %w(reaction lte effect-watcher)
    
    def foes
      GameObj.targets.map {|f| Creature.new(f)}.select {|f| f.tags.include?(:bandit)}
    end

    def entry
      Room.current.find_nearest self.rooms.map(&:id)
    end

    def rooms
      @_subgraph ||= Room.list.select {|r| r.location.is_a?(String) && r.location.include?(Bounty.area)}
    end

    def self.setup
      Char.arm
      if Group.empty?
        Script.run("go2", "%s --disable-confirm" % self.entry)
      else
        Script.run("rally", "%s" % self.entry)
      end
    end

    def self.main
      while Bounty.type.eql?(:bandits)
        (proposed_action, foe) = self.best_action
        Action.call(proposed_action, foe)
        Log.out("proposed.action=%s foe=%s" % [proposed_action.to_sym, foe.name], label: %i(bandits logic)) unless proposed_action.eql?(@previous_action)
        @previous_action = proposed_action
        sleep 0.1
      end
    end

    def self.teardown
      Teardown.new(self).apply()
    end
  end
end