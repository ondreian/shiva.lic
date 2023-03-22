module Shiva
  class SymbolOfDisruption < Action
    def priority
      Priority.get(:high)
    end

    def active?
      Effects::Buffs.active?("Symbol of Disruption")
    end

    def available?
      %i(plane4).include?(self.env.name) and
      Society.status.eql?("Order of Voln") and
      Society.rank > 20 and
      not self.active?
    end

    def apply()
      ttl = Time.now + 2
      fput "symbol of disruption"
      wait_until {self.active? or Time.now > ttl}
    end
  end
end