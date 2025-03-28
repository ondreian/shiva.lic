module Shiva
  Environment.define :hw_gardens do
    @entry      = 30041
    @level      = (100..100)
    @boundaries = %w(29954 29948 30048 29953 30036)
    @town       = %[Hinterwilds]
    @foes       = %w(
      undansormr disir
      disciple mutant
      valravn angargeist
      draugr
      ooze oozeling
      golem bloodspeaker wendigo cannibal
    )
    @wandering_foes = %w(warg skald hinterboar mastodon berserker shield-maiden)

    def self.before_teardown
      Script.run("ring", "4") if defined? Ring and Ring.exists?
    end
  end
end