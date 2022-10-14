module Shiva
  Environment.define :plane4 do
    @entry      = 12145
    @town       = %[Icemule Trace]
    @scripts    = %w(reaction lte effect-watcher)
    @foes       = %w(crawler crusader cerebralite)
    @boundaries = %w(12122 12207 12235)

    def self.before_teardown
      Voln.fog
    end
  end
end