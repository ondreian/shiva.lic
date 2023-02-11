# glowing ethereal bracer
# https://gswiki.play.net/Ethereal_Bracer
module Shiva
  class EtherealBracer < Action
    @cooldown ||= Time.now - 1

    def self.cooldown
      @cooldown
    end

    def self.add_cooldown(min)
      @cooldown = Time.now + (min * 60)
    end

    def swarm?
      self.env.foes.size > 2
    end

    def priority
      self.swarm? ? 3 : 50
    end

    def bracer
      GameObj.inv.select(&Where[name: "glowing ethereal bracer"]).first
    end

    def available?(foe)
      not foe.nil? and
      not foe.name =~ /ethereal|spectral/ and
      EtherealBracer.cooldown < Time.now and
      not hidden? and
      not self.bracer.nil?
    end

    def shoot(foe)
      return if foe.dead? or foe.gone?
      fput "point #%s at #%s" % [self.bracer.id, foe.id]
      EtherealBracer.add_cooldown(2)
    end

    def aoe
      fput "raise #%s" % self.bracer.id
      EtherealBracer.add_cooldown(5)
    end

    def apply(foe)
      waitrt?
      return self.aoe if self.swarm?
      return self.shoot(foe)
    end
  end
end