module Shiva
  Environment.define :bandits do
    
    def foes
      GameObj.targets.map {|f| Creature.new(f)}.select {|f| f.tags.include?(:bandit)}
    end

    def entry
      self.rooms.map(&:id).sample
    end

    def rooms!
      @_subgraph = Room.list.select {|r| r.location.is_a?(String) && r.location.include?(Bounty.area)}
    end

    def rooms
      @_subgraph ||= self.rooms!
    end

    def crawl
      Bandits.crawl(self)
    end

    def candidates
      return Room.current.wayto.to_a
        .select do |id, movement| 
          movement.is_a?(String) && 
          self.rooms.any? {|r| r.id.to_s.eql?(id)} && 
          Room[id].wayto.any? {|id, movement| movement.is_a?(String)}  end
        .map(&:first)
    end

    def self.setup
      Script.run("shiva_setup") if Script.exists?("shiva_setup")
      self.rooms!
      Arms.use

      return if self.rooms.any? {|r| r.id.eql?(Room.current.id)}
      if Group.empty?
        Script.run("go2", "%s --disable-confirm" % self.entry)
      else
        Rally.group(self.entry)
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

      return unless Lich::Claim.mine?
      search = self.action(:loot)
      search.apply
      sleep 0.1
      loot = self.action(:lootarea)
      loot.apply
      Teleport.teleport(1) if defined?(Teleport) && Teleport.teleporter
    end

    def self.teardown
      Teardown.new(self).apply()
    end
  end
end