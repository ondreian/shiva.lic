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
      return -100 if self.overwhelmed?
      return Priority.get(:high) unless Lich::Claim.mine?
      return Priority.get(:high) unless (Config.flee & GameObj.targets.map(&:noun)).empty?
      Priority.get(:medium)
    end

    def recover_from_rifting()
      return :ok if self.env.rooms.include?(Room.current.id.to_s)
      Char.unhide if hidden?
      Log.out("recovering from being teleported...", label: %i(recover teleported))
      return Script.run("go2", self.env.entry.to_s)
    end

    def antimagic?
      self.env.name.eql?(:scatter) and %w(Wizard Empath Sorceror).include?(Char.prof) and 
      self.env.foes.map(&:name).any? {|name| name =~ /vvrael/i}
    end

    def overwhelmed?
      return true if GameObj.loot.find {|i| i.noun.eql?(%[phylactery])} and self.env.foes.map(&:noun).count {|n| n.eql?("lich")} > 0
      return true if self.env.foes.map(&:noun).count {|n| n.eql?("lich")} > 1
      return self.env.foes.size > self.max_foes
    end

    def max_foes
      return 3 if Skills.multiopponentcombat > 100 and Room.current.location.include?("Hinterwilds")
      return 2 if Skills.multiopponentcombat > 100 and Room.current.location.include?("Moonsedge")
      return 1 if Char.exp < 15_000_000 and Room.current.location.include?("Rift")
      return 1 if %w(Cleric Empath Wizard).include?(Char.prof)
      return 10 if self.env.name.eql?(:bandits)
      return 5 if self.env.name.eql?(:scatter_south)
      return 5 if Skills.multiopponentcombat > 100
      return 3 if Skills.multiopponentcombat > 50
      return Group.size + 1
    end

    def available?(foe)
      return false if Opts["manual"]
      return false if self.env.rooms.empty? #self.env.boundaries.is_a?(Array) and not self.env.boundaries.empty?
      return false if Script.running?("mend") && GameObj.targets.empty?
      return false unless Group.leader? or Group.empty?
      return false if Group.members.map(&:status).flatten.compact.size > 0
      return false if Injuries.wounds.any? {|w| w > 0} and Char.prof.eql?("Empath") and GameObj.targets.empty?
      return false if Injuries.scars.any? {|s| s > 0} and Char.prof.eql?("Empath") and GameObj.targets.empty?
      return self.reason.is_a?(Symbol)
    end

    def room_objs
      GameObj.loot.to_a.map(&:name)
    end

    def reason()
      return :claim  unless Lich::Claim.mine?
      return :monstrosity if GameObj.targets.any? {|f| f.noun.eql?("monstrosity")}
      return :brawlers    if GameObj.targets.map(&:noun).select {|n| n.eql?("brawler") or n.eql?("psionicist")}.size > 1
      return nil          if Script.running?("give")
      return :dolls       if GameObj.targets.any? {|f| f.noun.eql?("doll")}
      return :fissure     if checkloot.include?('fissure')
      return :flee        if Config.flee.is_a?(String) && GameObj.targets.any? {|f| Config.flee.include?(foe.noun)}
      return :swarm       if self.overwhelmed?
      return :magma       if self.room_objs.include?("mass of undulating liquified rock")
      return :cyclone     if self.room_objs.include?("frigid cyclone") and GameObj.targets.any? {|f| f.noun.eql?("wendigo")}
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
      if reason.eql?(:swarm) && @env.action(:divert).available?
        @env.action(:divert).apply
      else
        self.call_wayto self.paths.sample
        waitrt?
      end
    end

    def pre_move_hook()
      return unless Lich::Claim.mine?
      search = @env.action(:loot)
      search.apply unless self.overwhelmed?
      loot = @env.action(:lootarea)
      loot.apply
    end

    Stances = ["Duck and Weave"]

    def stance!
      return if Stances.any? {|stance| Effects::Spells.active?(stance)}
      Stance.defensive()
    end

    def apply()
      self.pre_move_hook
      waitcastrt?
      waitrt?
      self.stance!
      case self.env.name.downcase.to_sym
      when :bandits
        Log.out("wander -> bandits", label: %i(action))
        #Stance.forward
        self.env.crawl
      else
        self.wander(reason: self.reason)
      end
    end
  end
end