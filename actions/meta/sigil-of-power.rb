module Shiva
  class SigilOfPower < Action
    def priority
      Priority.get(:high)
    end

    def available?
      self.env.foes.empty? and
      Society.status.eql?("Guardians of Sunfist") and
      (maxmana - checkmana) >= 50 and
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