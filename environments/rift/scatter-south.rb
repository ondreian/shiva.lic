module Shiva
  Environment.define :scatter_south do
    @entry      = 12256
    @town       = %[Icemule Trace]
    @scripts    = %w(reaction)
    @foes       = %w(lich siphon master destroyer cerebralite doll)
    @wandering_foes = %w(crawler)
    @boundaries = %w(12151 12219 12217 12233 12237 12239)
    @level      = (100..110)

    def self.before_main
      #Boost.loot
    end

    def self.before_teardown
      Voln.fog
    end
  end
end