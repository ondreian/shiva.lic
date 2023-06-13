module Shiva
  Environment.define :scatter do
    @entry      = 12240
    @town       = %[Icemule Trace]
    @scripts    = %w(reaction)
    @foes       = %w(siphon master destroyer cerebralite doll)
    @wandering_foes = %w(crawler)
    @boundaries = %w(12151 12254 12256 12249 12247 12241)
    @level      = (100..110)

    def self.before_main
      Boost.loot
    end

    def self.before_teardown
      Voln.fog
    end
  end
end