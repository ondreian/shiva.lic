module Shiva
  class SigilOfPower < Action
    def priority
      Priority.get(:medium)
    end

    def available?
      Society.status.eql?("Guardians of Sunfist") and
      (Char.max_mana - checkmana) >= 50 and
      checkstamina > 50 and
      not Effects::Debuffs.active?("Overexerted")
    end

    def apply()
      last_mana = checkmana
      ttl = Time.now + 2
      fput "sigil power"
      wait_until {checkmana > last_mana or Time.now > ttl}
    end
  end
end