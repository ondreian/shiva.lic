module Shiva
  class Flurry < Action
    def priority
      40
    end

    def cost
      Effects::Buffs.active?("Stamina Second Wind") ? 0 : 15
    end

    def available?(foe)
      not Tactic.thrown? and
      not %i(duskruin).include?(self.env.name) and
      not foe.nil? and
      not Effects::Cooldowns.active?("Flurry") and
      not Effects::Buffs.active?("Slashing Strikes") and
      not Spell[117].active? and
      Tactic.edged? and
      checkstamina > (self.cost * 3) and
      not hidden? and
      self.env.foes.size < 4
    end

    def flurry(foe)
      Timer.await() if checkrt > 5
      Stance.offensive
      fput "weapon flurry #%s" % foe.id
      ttl = Time.now + 5
      while line=get
        break if line.include?("...wait")
        break if line.include?("The mesmerizing sway of body and blade glides to its inevitable end")
        break unless GameObj[foe.id]
        break if foe.dead? or foe.gone?
        break if Time.now > ttl
      end
    end

    def apply(foe)
      return self.flurry foe
    end
  end
end