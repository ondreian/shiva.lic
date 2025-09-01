module Shiva
  Environment.define :hw_pits do
    @entry      = 29966 #29993
    @level      = (100..100)
    @boundaries = %w(29994 29965)
    @town       = %[Hinterwilds]
    @foes       = %w(
      undansormr disir
      disciple mutant
      valravn angargeist
      draugr
      ooze oozeling
      golem bloodspeaker wendigo cannibal
      warg skald hinterboar mastodon berserker shield-maiden
    )
    @wandering_foes = %w()

    def self.before_teardown
      return unless defined?(Teleport)
      slot = Teleport::Anchors.find {|anchor| anchor.room.id.eql?(29881)}
      return if slot.nil?
      Script.run("teleport", "%s" % slot.position)
      #Script.run("teleport", "4") if Teleport.teleporter.name
    end
  end
end