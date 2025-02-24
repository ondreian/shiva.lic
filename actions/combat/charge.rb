module Shiva
  Charged = []
  class Charge < Action
    def priority
      (30..90).to_a.sample
    end

    def available?(foe)
      not foe.nil? and
      foe.status.empty? and
      Wounds.leftLeg < 2 and
      Wounds.rightLeg < 2 and
      Tactic.polearms? and
      checkstamina > 30 and
      not foe.type.include?("noncorporeal") and
      not Charged.include?(foe.id) and
      not hidden? and
      rand > 0.6
    end

    def charge(foe)
      Stance.offensive
      fput "weapon charge #%s" % foe.id
      Charged << foe.id
      Timer.await()
    end

    def apply(foe)
      return self.charge foe
    end
  end
end