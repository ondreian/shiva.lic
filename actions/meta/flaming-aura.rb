# perm flaming aura item
module Shiva
  class PermaFlamingAura < Action
    def priority
      Priority.get(:high)
    end

    def coil
      GameObj.inv.find {|i| i.name.eql? %[slim firestone coil]}
    end

    def active?
      Effects::Spells.active?("Flaming Aura")
    end

    def available?(foe)
      return false if %w(Rogue).include? Char.prof
      return false unless Skills.magicitemuse > 5
      return false if self.coil.nil?
      return false if self.active?
      return false if Feat.kroderine_soul > 0
      return self.env.foes.size.eql? 0
    end

    def apply()
      waitcastrt?
      waitrt?
      dothistimeout "rub #%s" % self.coil.id, 2, /Wisps of ethereal blue flame enshroud your form!/
      ttl = Time.now + 2
      wait_until {self.active? or Time.now > ttl}
    end
  end
end