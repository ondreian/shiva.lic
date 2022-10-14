module Shiva
  class Fire < Action
    def priority
      80
    end


    def available?(foe)
      not foe.nil? and
      Tactic.ranged?
    end

    def shoot(foe)
      Timer.await()
      Stance.offensive
      foe.fire()
      Char.aim foe.kill_shot Aiming.lookup(foe) unless foe.dead? or foe.gone?
    end

    def apply(foe)
      Log.out("{foe=%s, level=%s}" % [foe.name, foe.level], label: %i(foe))
      return self.shoot foe
    end
  end
end