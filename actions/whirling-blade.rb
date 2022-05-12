module Shiva
  class WhirlingBlade < Action
    def priority
      5
    end

    def available?(foe)
      not Effects::Cooldowns.active?("Whirling Blade") and
      Skills.edgedweapons > 150 and
      checkstamina > 50 and
      not hidden? and
      self.env.foes.size > 2 and
      not foe.nil? and
      rand > 0.6
    end

    def wblade(foe)
      Timer.await() if checkrt > 5
      Stance.offensive
      fput "weapon wblade"
    end

    def apply(foe)
      return self.wblade foe
    end
  end
end