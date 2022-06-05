module Shiva
  class WizardShield < Action
    def priority
      Priority.get(:medium)
    end

    def available?
      Spell[919].known? and
      checkmana > 100 and
      not Spell[919].active?
    end

    def apply()
      fput "incant 919"
    end
  end
end