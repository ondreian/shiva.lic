module Shiva
  class SymbolOfProtection < Action
    def priority
      10
    end

    def available?
      return false
      Society.status.eql?("Order of Voln") and
      not Effects::Buffs.active?("Symbol of Protection")
    end

    def apply()
      ttl = Time.now + 2
      fput "symbol of prot"
      wait_until {Effects::Buffs.active?("Symbol of Protection") or Time.now > ttl}
    end
  end
end