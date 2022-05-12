module Shiva
  class Wander < Action
    def paths
      Room.current.wayto.select {|id, wayto| self.env.rooms.include?(id)}.map(&:last)
    end

    def call_wayto(wayto)
      if wayto.is_a?(Proc)
        wayto.call
      else
        move wayto, 2
      end
    end

    def priority
      GameObj.targets.map(&:noun).include?("monstrosity") ? 4 : 8
    end

    def antimagic?
      self.env.name.eql?(:scatter) and %w(Wizard Empath Sorceror).include?(Char.prof) and 
      self.env.foes.map(&:name).any? {|name| name =~ /vvrael/i}
    end

    def max_foes
      return 5 if Skills.multiopponentcombat > 100
      return Group.size + 1
    end

    def available?(foe)
      return false unless self.env.boundaries.is_a?(Array) and not self.env.boundaries.empty?
      return false if Script.running?("mend")
      return false unless Group.leader? or Group.empty?
      return false if Group.members.map(&:status).flatten.compact.size > 0
      return true if self.antimagic?
      return true if GameObj.targets.any? {|foe| foe.noun.eql?("monstrosity")} and Group.empty?
      #return true if Group.empty? and self.env.foes.size > 1 and self.env.is?(Shiva::Sanctum)
      #return true if Skills.multiopponentcombat < 30 and self.env.foes.select {|f| f.status.empty? }.size > 1 and Group.empty?
      return true if self.env.foes.size > self.max_foes
      return true if GameObj.loot.to_a.map(&:name).include?("mass of undulating liquified rock")
      return true if checkloot.include?('fissure')
      return true if foe.nil?
      return true unless Claim.mine?
      return false if (Group.members.map(&:noun) - checkpcs.to_a).size > 0
      return false
    end

    def recover_from_rifting()
      return if XMLData.room_title.eql?("[The Rift, Scatter]")
      Char.unhide if Char.hidden?
      Log.out("recovering from being rifted...", label: %i(recover rifted))
      return Script.run("go2", "scatter")
    end

    def wander(reason: nil)
      Log.out("reason=%s uuid=%s" % [reason, XMLData.room_id], label: %i(wander reason)) unless reason.nil?
      Char.stand unless standing?
      loot = @controller.action(:lootarea)
      loot.apply if Claim.mine?
      Log.out(self.paths.join(", "), label: %i(wander paths))
      self.call_wayto self.paths.sample
      waitrt?
      return self.wander(reason: :claim) unless Claim.mine?
      return self.wander(reason: :fissure) if checkloot.include?('fissure')
      return self.wander(reason: :swarm) if self.env.foes.size > self.max_foes
      return self.wander(reason: :magma) if GameObj.loot.to_a.map(&:name).include?("mass of undulating liquified rock")
      return self.wander(reason: :poach) if (checkpcs.to_a - Cluster.connected).size > 0
      :mine
    end

    def apply()
      loot = @controller.action(:lootarea)
      loot.apply if Claim.mine?
      waitcastrt?
      waitrt?
      case self.env.name.downcase.to_sym
      when :bandits
        Log.out("wander -> bandits", label: %i(action))
        Stance.forward
        Bandits.crawl(self.env.area)
      when :scatter
        self.recover_from_rifting
        self.wander
      else
        self.wander
      end
    end
  end
end