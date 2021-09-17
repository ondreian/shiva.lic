module Shiva
  class SymbolOfProtection < Action
    def priority
      10
    end

    def available?
      Society.status.eql?("Order of Voln") and
      not Effects::Buffs.active?("Symbol of Protection")
    end

    def apply()
      last_mana = checkmana
      ttl = Time.now + 2
      fput "symbol of prot\rspell active"
      wait_until {Effects::Buffs.active?("Symbol of Protection") or Time.now > ttl}
    end
  end
end