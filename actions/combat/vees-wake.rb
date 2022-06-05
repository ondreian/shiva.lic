module Shiva
  class VeesWake < Action
    def aiming(foe)
      return %i(head neck back) if %w(crab).include?(foe.noun)
      return %i(left_eye right_eye head neck back)
    end

    def priority
      90
    end

    def holding_harpoon?
      Char.right.name.eql?("sea glaes harpoon") and
      Skills.elwater > 24
    end

    def available?(foe)
      not foe.nil? and
      Skills.thrownweapons > Char.level and
      Skills.polearmweapons > Char.level and
      self.holding_harpoon? and
      Char.mana > 30
    end

    def hurl(foe)
      Timer.await()
      Stance.offensive
      foe.hurl()
      Char.aim foe.kill_shot self.aiming(foe) unless foe.dead? or foe.gone?
    end

    def apply(foe)
      Log.out("{foe=%s, level=%s}" % [foe.name, foe.level], label: %i(foe))
      return self.hurl foe
    end
  end
end