module Shiva
  Environment.define :plane4 do
    @entry      = 12145
    @town       = %[Icemule Trace]
    @scripts    = %w(reaction)
    @foes       = %w(crawler crusader cerebralite)
    @boundaries = %w(12122 12207 12235)
    @level      = (98..105)

    def self.before_main
      Boost.loot
    end

    def self.before_teardown
      Voln.fog
    end
  end
end