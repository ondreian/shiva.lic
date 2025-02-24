module Shiva
  class SymbolOfSupremacy < Action
    def priority
      Priority.get(:high)
    end

    def active?
      Effects::Buffs.active?("Symbol of Supremacy")
    end

    def available?
      %i(moonsedge_castle moonsedge_village).include?(self.env.name) and
      Society.status.eql?("Order of Voln") and
      Society.rank > 20 and
      not self.active?
    end

    def apply()
      ttl = Time.now + 2
      fput "symbol of supremacy"
      wait_until {self.active? or Time.now > ttl}
    end
  end
end