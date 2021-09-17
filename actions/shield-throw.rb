module Shiva
  class ShieldThrow < Action
    def priority
      5
    end

    def available?(foe)
      checkrt < 1 and
      not Effects::Debuffs.active?("Jaws") and
      not foe.nil? and
      not foe.tags.include?(:undead) and
      not Effects::Cooldowns.active?("Shield Throw") and
      Skills.shielduse > 150 and
      %w(Warrior Rogue).include?(Char.prof) and
      checkstamina > 80 and
      not hidden? and
      @env.foes.size > 1
    end

    def shield_throw(foe)
      Timer.await() if checkrt > 5
      Stance.offensive
      fput "shield throw"
    end

    def apply(foe)
      return self.shield_throw foe
    end
  end
end