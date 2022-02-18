module Shiva
  class Rest < Action
    Injuries = Wounds.singleton_methods
      .map(&:to_s)
      .select do |m| m.downcase == m && m !~ /_/ end.map(&:to_sym)

    def priority
      1
    end

    def allowed
      [Shiva::Scatter, Shiva::Sanctum]
    end

    def wounds
      Injuries.map {|m| Wounds.send(m)}
    end

    def out_of_mana?
      return false if %w(Warrior Rogue Monk).include?(Char.prof)
      return true  if percentmana < 20 and Char.prof.eql?("Bard")
      return true  if percentmana < 10
      return false
    end

    def available?(foe)
      return false unless Group.leader?
      return true if Char.left.type =~ /box/
      return true if @env.state.eql?(:rest)
      return true if percentencumbrance > 10
      return true if self.wounds.any? {|w| w > 1}
      return true if percenthealth < 80
      return self.out_of_mana?
    end

    def base
      18698 # Oberwood
    end

    def others
      (checkpcs.to_a - Cluster.connected).size > 0
    end

    def box?
      GameObj.loot.any? {|i| i.type =~ /box/}
    end

    def transport
      if Group.empty?
        Script.run("go2", self.base.to_s)
      else
        $cluster_cli.stop("shiva") if Group.leader? and not Group.empty?
        Script.run("rally", self.base.to_s)
        fput "disband"
      end
    end

    def apply()
      case @env.name.downcase.to_sym
      when :scatter
        from_id = Room.current.id
        waitcastrt?
        waitrt?
        fput "symbol return"
        ttl = Time.now + 2
        wait_while {Room.current.id.eql?(from_id) and Time.now < ttl}
        # retry
        return if Room.current.id.eql?(from_id)
      end
      self.transport
      ttl = Time.now + 10
      wait_until("waiting on return to base...") {
        Room.current.id.eql?(self.base) or (Time.now > ttl and not Script.running?("go2"))
      }
      fail "could not return to base" unless Room.current.id.eql?(self.base)
      Team.request_healing
      Char.unarm
      wait_while("waiting on hands") {Char.left or Char.right} unless Char.left.type =~ /box/
      unless self.others and self.box?
        Script.run("boxes", "drop") 
        Script.run("spa", "--floor --loot") if Char.name.eql?("Ondreian")
      end
      Script.run("give", "all uncut (diamond|emerald) Szan") if checkpcs.include?("Szan")
      if Char.name.eql?("Szan")
        Script.run("prune-gems")
        Script.run("sell", "--deposit")
      else
        Script.run("sell", "--deposit --gems")
      end
      Script.start("waggle")
      exit
    end
  end
end