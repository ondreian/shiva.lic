module Shiva
  Environment.define :boreal_forest do
    @entry      = 29882
    @level      = (100..100)
    @boundaries = %w(29878 29949 30115 29901 29938 29902 29881)
    @town       = %[Hinterwilds]
    @scripts    = %w(reaction)
    @foes       = %w(golem bloodspeaker wendigo cannibal)
    @wandering_foes = %w(warg skald hinterboar mastodon berserker shield-maiden)

    def self.before_teardown
      Script.run("ring", "4") if defined? Ring and Ring.exists?
    end
  end
end