module Shiva
  Environment.define :nelemar do
    @entry      = 12701
    @boundaries = %w(20786 12677)
    @town       = %[Kharam-Dzu]
    @scripts    = %w(reaction)
    @foes       = %w(dissembler magus elemental executioner defender combatant radical sentry siren)
    @level      = (95..105)

    def self.before_main
      #Boost.loot
    end

    def self.before_teardown
      fput "symbol of return"
    end
  end
end