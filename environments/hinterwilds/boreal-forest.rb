module Shiva
  Environment.define :borealforest do
    @entry      = 29882
    @boundaries = %w(29878 29949 30115 29901 29938 29902)
    @town       = %[Hinterwilds]
    @scripts    = %w(reaction lte effect-watcher)
    @foes       = %w(
        wendigo warg hinterboar bloodspeaker cannibal
        golem mastodon berserker skald shield-maiden
      )
  end
end