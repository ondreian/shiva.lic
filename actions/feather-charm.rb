module Shiva
  class FeatherCharm < Action
    def priority
      4
    end

    def charm
      GameObj.inv.find {|i| i.name =~ /blue feather-shaped charm/}
    end

    def active?
      Effects::Spells.active?("Feather Charm")
    end

    def available?(foe)
      (foe.nil? or hidden?) and
      not self.charm.nil? and
      not self.active? and
      percentencumbrance > 0
    end

    def apply()
      fput "rub #%s" % [self.charm.id]
      ttl = Time.now + 2
      wait_until {self.active? or Time.now > ttl}
    end
  end
end