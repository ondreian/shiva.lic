module Shiva
  class AdrenalSurge < Action
    def priority
      5
    end

    def available?
      Spell[1107].affordable? and
      Spell[1107].known? and
      Skills.slblessings > 64 and
      checkstamina < 50 and
      not Effects::Cooldowns.active?("Adrenal Surge") and
      self.env.foes.empty?
    end

    def apply()
      Spell[1107].cast
    end
  end
end