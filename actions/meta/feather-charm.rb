module Shiva
  class FeatherCharm < Action
    def priority
      Priority.get(:high) - 10
    end

    def charm
      GameObj.inv.find {|i| i.name =~ /blue feather-shaped charm/} or
      GameObj.inv.find {|i| i.name =~ /golden feather charm/}
    end

    def active?
      Effects::Spells.active?("Feather Charm")
    end

    def loot_boost?
      Effects::Buffs.active?("Major Loot Boost") or Effects::Buffs.active?("Minor Loot Boost")
    end

    def available?(foe)
      (foe.nil? or hidden?) and
      not self.charm.nil? and
      not self.active? and
      self.loot_boost? and
      percentencumbrance > 0
    end

    def apply()
      fput "rub #%s" % [self.charm.id]
      ttl = Time.now + 2
      wait_until {self.active? or Time.now > ttl}
    end
  end
end