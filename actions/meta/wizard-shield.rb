module Shiva
  class WizardShield < Action
    def priority
      Priority.get(:medium)
    end

    def available?
      return false
      Spell[919].known? and
      checkmana > 100 and
      not Spell[919].active?
    end

    def apply()
      Spell[919].cast
      ttl = Time.now + 3
      wait_until {Spell[919].active? or Time.now > ttl}
    end
  end
end