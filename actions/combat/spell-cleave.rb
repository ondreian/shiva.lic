module Shiva
  class SpellCleave < Action
    def priority
      5
    end

    def available?(foe)
      not Effects::Cooldowns.active?("Spell Cleave") and
      CMan.spell_cleave > 3 and
      checkstamina > 50 and
      not hidden? and
      %w(brawler).include?(foe.noun)
    end

    def spell_cleave(foe)
      Timer.await() if checkrt > 5
      Stance.offensive
      fput "cman scleave #%s" % foe.id
    end

    def apply(foe)
      return self.spell_cleave foe
    end
  end
end