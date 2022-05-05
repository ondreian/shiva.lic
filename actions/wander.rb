module Shiva
  class Wander < Action
    AllowedWays = %w(
               nw n ne
               w  out  e
               sw s se
               up down)

    def paths
      (AllowedWays & checkpaths) + self.allowed_portals
    end

    def allowed_portals
      %w(spire).select {|noun| GameObj.loot.map(&:noun).include?(noun)}
        .map {|noun| "go %s" % noun}
    end

    def priority
      GameObj.targets.map(&:noun).include?("monstrosity") ? 4 : 8
    end

    def allowed
      [Shiva::Bandits, Shiva::Scatter, Shiva::Sanctum]
    end

    def antimagic?
      @env.is?(Shiva::Scatter) and %w(Wizard Empath Sorceror).include?(Char.prof) and @env.foes.map(&:name).any? {|name| name =~ /vvrael/i}
    end

    def max_foes
      return 5 if Char.name.eql?("Ondreian")
      return Group.size + 1
    end

    def available?(foe)
      return false if Script.running?("mend")
      return false unless Group.leader? or Group.empty?
      return false if Group.members.map(&:status).flatten.compact.size > 0
      return true if self.antimagic?
      return true if GameObj.targets.any? {|foe| foe.noun.eql?("monstrosity")} and Group.empty?
      #return true if Group.empty? and @env.foes.size > 1 and @env.is?(Shiva::Sanctum)
      #return true if Skills.multiopponentcombat < 30 and @env.foes.select {|f| f.status.empty? }.size > 1 and Group.empty?
      return true if @env.foes.size > self.max_foes
      return true if GameObj.loot.to_a.map(&:name).include?("mass of undulating liquified rock")
      return true if checkloot.include?('fissure')
      return true if foe.nil?
      return true unless Claim.mine?
      return false if (Group.members.map(&:noun) - checkpcs.to_a).size > 0
      return false
    end

    def wander(reason: nil)
      Log.out("reason=%s uuid=%s" % [reason, XMLData.room_id], label: %i(wander reason)) unless reason.nil?
      #start_id = XMLData.room_id
      #ttl = Time.now + 3
      Char.stand unless standing?
      loot = @env.action("LootArea")
      loot.apply if Claim.mine?
      Log.out(self.paths.join(", "), label: %i(wander paths))
      move self.paths.sample, 2
      waitrt?
      #wait_while("waiting on room change") {XMLData.room_id.eql?(start_id) and Time.now < ttl}
      return self.wander(reason: :claim) unless Claim.mine?
      return self.wander(reason: :fissure) if checkloot.include?('fissure')
      return self.wander(reason: :swarm) if GameObj.targets.size > 3
      return self.wander(reason: :magma) if GameObj.loot.to_a.map(&:name).include?("mass of undulating liquified rock")
      return self.wander(reason: :poach) if (checkpcs.to_a - Cluster.connected).size > 0
      :mine
    end

    def apply()
      loot = @env.action("LootArea")
      loot.apply if Claim.mine?
      waitcastrt?
      waitrt?
      case @env.name.downcase.to_sym
      when :bandits
        Log.out("wander -> bandits", label: %i(action))
        Stance.forward
        Bandits.crawl(@env.area)
      when :scatter
        unless XMLData.room_title.eql?("[The Rift, Scatter]")
          Char.unhide if Char.hidden?
          Log.out("recovering from being rifted...", label: %i(recover rifted))
          return Script.run("go2", "scatter")
        end
        self.wander
      when :sanctum
        #Char.unhide
        self.wander
      else
        fail "wander not implemented for {env=#{@env.name}} yet!"
      end
    end
  end
end