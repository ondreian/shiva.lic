module Shiva
  Environment.define :scatter do
    @entry      = 12240
    @town       = %[Icemule Trace]
    @scripts    = %w(reaction lte effect-watcher)
    @foes       = %w(crawler siphon master destroyer cerebralite doll)
    @boundaries = %w(12151 12254 12256 12249 12247 12241)

    def self.before_teardown
      Voln.fog
    end
  end
end