module Shiva
  class SymbolOfCourage < Action
    def priority
      5
    end

    def available?
      Society.status.eql?("Order of Voln") and
      not Effects::Buffs.active?("Symbol of Courage")
    end

    def apply()
      ttl = Time.now + 2
      fput "symbol of courage"
      wait_until {Effects::Buffs.active?("Symbol of Courage") or Time.now > ttl}
    end
  end
end