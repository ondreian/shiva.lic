module Shiva
  class SymbolOfCourage < Action
    @tags = %i(setup)
    
    def priority
      Priority.get(:high)
    end

    def available?
      Society.status.eql?("Order of Voln") and
      Society.rank > 10 and
      not Effects::Buffs.active?("Symbol of Courage")
    end

    def apply()
      ttl = Time.now + 2
      fput "symbol of courage"
      wait_until {Effects::Buffs.active?("Symbol of Courage") or Time.now > ttl}
    end
  end
end