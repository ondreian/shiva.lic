module Shiva
  class WizardShield < Action
    def priority
      5
    end

    def available?
      Spell[919].known? and
      Spell[919].affordable? and
      not Spell[919].active?
    end

    def apply()
      fput "incant 919"
    end
  end
end