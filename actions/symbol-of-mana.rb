module Shiva
  class SymbolOfMana < Action
    def priority
      1_000
    end

    def available?
      Society.status.eql?("Order of Voln") and
      (Char.max_mana - checkmana) >= 100 and
      not Effects::Cooldowns.active?("Symbol of Mana")
    end

    def apply()
      last_mana = checkmana
      ttl = Time.now + 2
      fput "symbol of mana"
      wait_until {checkmana > last_mana or Time.now > ttl}
      wait_until {Effects::Cooldowns.active?("Symbol of Mana") or Time.now > ttl}
    end
  end
end