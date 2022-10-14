module Shiva
  class SymbolOfProtection < Action
    def priority
      Priority.get(:high)
    end

    def available?
      Society.status.eql?("Order of Voln") and
      Society.rank > 10 and
      not Effects::Buffs.active?("Symbol of Protection")
    end

    def apply()
      ttl = Time.now + 2
      fput "symbol of prot"
      wait_until {Effects::Buffs.active?("Symbol of Protection") or Time.now > ttl}
    end
  end
end