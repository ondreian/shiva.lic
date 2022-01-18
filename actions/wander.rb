module Shiva
  class Wander < Action
    AllowedWays = %w(
               nw n ne
               w  out  e
               sw s se
               up down)

    def paths
      AllowedWays & checkpaths
    end

    def priority
      8
    end

    def allowed
      [Shiva::Bandits, Shiva::Scatter, Shiva::Sanctum]
    end

    def available?(foe)
      return false unless Group.leader? or Group.empty?
      return false if Group.members.map(&:status).flatten.compact.size > 0
      return true if @env.foes.size > 3 and Group.empty?
      return true if not Group.empty? and @env.foes.size > Group.size
      return true if GameObj.loot.to_a.map(&:name).include?("mass of undulating liquified rock")
      return true if checkloot.include?('fissure')
      return true if foe.nil?
      return true unless Claim.mine?
      return false if (Group.members.map(&:noun) - checkpcs.to_a).size > 0
      return false
    end

    def wander
      sleep 0.1
      move self.paths.sample
      waitrt?
      self.wander if checkloot.include?('fissure')
      self.wander if GameObj.targets.size > 3
      self.wander if GameObj.loot.to_a.map(&:name).include?("mass of undulating liquified rock")
      self.wander unless Claim.mine?
      self.wander if (checkpcs.to_a - Cluster.connected).size > 0
    end

    def apply()
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