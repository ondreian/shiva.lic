module Shiva
  class Wander < Action
    def paths
      Room.current.wayto.select {|id, wayto|
        self.env.rooms.include?(id) and wayto.is_a?(String)
      }.map(&:last)
    end

    def call_wayto(wayto)
      if wayto.is_a?(Proc)
        wayto.call
      else
        move wayto, 2
      end
    end

    def priority
      GameObj.targets.map(&:noun).include?("monstrosity") ? 2 : 8
    end

    def recover_from_rifting()
      return :ok if self.env.rooms.include?(Room.current.id.to_s)
      Char.unhide if Char.hidden?
      Log.out("recovering from being teleported...", label: %i(recover teleported))
      return Script.run("go2", self.env.entry.to_s)
    end

    def antimagic?
      self.env.name.eql?(:scatter) and %w(Wizard Empath Sorceror).include?(Char.prof) and 
      self.env.foes.map(&:name).any? {|name| name =~ /vvrael/i}
    end

    def max_foes
      return 3 if Skills.multiopponentcombat > 100 and Room.current.location.include?("Hinterwilds")
      return 5 if Skills.multiopponentcombat > 100
      return Group.size + 1
    end

    def available?(foe)
      return false if Opts["manual"]
      return false unless self.env.boundaries.is_a?(Array) and not self.env.boundaries.empty?
      return false if Script.running?("mend")
      return false unless Group.leader? or Group.empty?
      return false if Group.members.map(&:status).flatten.compact.size > 0
      return false if Char.total_wound_severity > 0 and Char.prof.eql?("Empath") and GameObj.targets.empty?
      return self.reason != false
    end

    def room_objs
      GameObj.loot.to_a.map(&:name)
    end

    def reason()
      return :claim       unless Claim.mine?
      return :monstrosity if GameObj.targets.any? {|f| f.noun.eql?("monstrosity")}
      return :fissure     if checkloot.include?('fissure')
      return :swarm       if self.env.foes.size > self.max_foes
      return :magma       if self.room_objs.include?("mass of undulating liquified rock")
      return :cyclone     if self.room_objs.include?("frigid cyclone")
      return :antimagic   if self.antimagic?
      return :empty       if self.env.foes.empty?
      return false
    end

    def wander(reason: nil)
      return if reason == false
      self.recover_from_rifting
      #sleep 0.1
      Log.out("reason=%s uuid=%s" % [reason, XMLData.room_id], label: %i(wander reason)) unless reason.nil?
      Char.stand unless standing?
      # Log.out(self.paths.join(", "), label: %i(wander paths))
      self.call_wayto self.paths.sample
      waitrt?
      #r = self.reason
      #return :mine if r == false
      #return self.wander(reason: r, tries: tries + 1)
    end

    def pre_move_hook()
      return unless Claim.mine?
      search = @controller.action(:loot)
      search.apply
      loot = @controller.action(:lootarea)
      loot.apply
    end

    def apply()
      self.pre_move_hook
      waitcastrt?
      waitrt?
      case self.env.name.downcase.to_sym
      when :bandits
        Log.out("wander -> bandits", label: %i(action))
        Stance.forward
        Bandits.crawl(self.env.area)
      else
        self.wander(reason: self.reason)
      end
    end
  end
end