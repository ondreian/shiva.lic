module Shiva
  Environment.define :boreal_forest do
    @entry      = 29882
    @level      = (100..100)
    @boundaries = %w(29878 29949 30115 29901 29938 29902)
    @town       = %[Hinterwilds]
    @scripts    = %w(reaction effect-watcher)
    @foes       = %w(golem bloodspeaker wendigo cannibal)
    @wandering_foes = %w(warg skald hinterboar mastodon berserker shield-maiden)
  end
end