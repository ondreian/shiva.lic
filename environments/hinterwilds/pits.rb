module Shiva
  Environment.define :pits do
    @entry      = 29966 #29993
    @level      = (100..110)
    @boundaries = %w(29994 29965)
    @town       = %[Hinterwilds]
    @foes       = %w(
      disir
      valravn
      angargeist
      draugr
      ooze oozeling
      packmother
    )
    @wandering_foes = %w(
      undansormr mutant disciple
      golem bloodspeaker wendigo cannibal
      warg skald hinterboar mastodon berserker shield-maiden
    )

    def self.before_teardown
      respond "...teardown..."
      return unless defined?(Teleport)
      slot = Teleport::Anchors.find {|anchor| anchor.room.id.eql?(29881)}
      return if slot.nil?
      Script.run("teleport", "%s" % slot.position)
      #Script.run("teleport", "4") if Teleport.teleporter.name
    end
  end
end