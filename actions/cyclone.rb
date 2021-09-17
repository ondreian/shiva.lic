module Shiva
  class Cyclone < Action
    def priority
      (6...100).to_a.sample
    end

    def available?(foe)
      not Effects::Debuffs.active?("Jaws") and
      not Effects::Cooldowns.active?("Cyclone") and
      Skills.polearmweapons > 150 and
      Skills.thrownweapons > 150 and
      checkstamina > 50 and
      not hidden? and
      @env.foes.size > 2 and
      not foe.nil? and
      rand > 0.6
    end

    def cyclone(foe)
      Timer.await() if checkrt > 5
      Stance.offensive
      fput "weapon cyclone"
    end

    def apply(foe)
      return self.cyclone foe
    end
  end
end