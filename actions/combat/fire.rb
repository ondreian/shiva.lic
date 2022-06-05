module Shiva
  class Fire < Action
    def aiming(foe)
      return %i(head neck back) if %w(crab).include?(foe.noun)
      return %i(left_eye right_eye head neck back)
    end

    def priority
      90
    end

    def holding_bow?
      Char.right.noun.eql?("bow")
    end

    def available?(foe)
      not foe.nil? and
      Skills.rangedweapons > Char.level * 1.5 and
      self.holding_bow?
    end

    def shoot(foe)
      Timer.await()
      Stance.offensive
      foe.fire()
      Char.aim foe.kill_shot self.aiming(foe) unless foe.dead? or foe.gone?
    end

    def apply(foe)
      Log.out("{foe=%s, level=%s}" % [foe.name, foe.level], label: %i(foe))
      return self.shoot foe
    end
  end
end