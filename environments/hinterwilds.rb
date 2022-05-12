module Shiva
  Environment.define :hinterwilds do
    @entry   = nil
    @town    = %[Cold River]
    @scripts = %w(reaction lte effect-watcher)
    @foes    = %w(
        warg hinterboar wendigo bloodspeaker cannibal
        golem berserker skald shield-maiden mastodon
      )
  end
end