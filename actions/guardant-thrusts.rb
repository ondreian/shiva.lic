module Shiva
  class GuardantThruster < Action
    def priority
      rand > 0.5 ? 6 : 40
    end

    def available?(foe)
      not foe.nil? and
      @env.foes.size < 2 and
      not Effects::Cooldowns.active?("Guardant Thrusts") and
      Skills.polearmweapons > 150 and
      checkstamina > 50 and
      not hidden? and
      @env.foes.size > 2 and
      rand > 0.6
    end

    def guardant_thrusts(foe)
      Timer.await() if checkrt > 5
      Stance.offensive
      fput "weapon gthrust #%s" % foe.id
      while line=get
        break if line.include?("You complete your assault, your weight on your rear foot")
        break unless GameObj[foe.id]
      end
    end

    def apply(foe)
      return self.guardant_thrusts foe
    end
  end
end