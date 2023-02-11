module Shiva
  Environment.define :scatter do
    @entry      = 12240
    @town       = %[Icemule Trace]
    @scripts    = %w(reaction lte effect-watcher)
    @foes       = %w(siphon master destroyer cerebralite doll)
    @wandering_foes = %w(crawler)
    @boundaries = %w(12151 12254 12256 12249 12247 12241)
    @level      = (100..110)

    def self.before_main
      Boost.loot if not Bounty.type.eql?(:none) and Time.now.day < 18
    end

    def self.before_teardown
      Voln.fog
    end
  end
end