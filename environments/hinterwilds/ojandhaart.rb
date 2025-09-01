module Shiva
  Environment.define :ojandhaart do
    @entry      = 29902
    @level      = (100..100)
    @boundaries = %w(30115 29900 29881)
    @town       = %[Hinterwilds]
    @scripts    = %w(reaction)
    @foes       = %w(warg skald hinterboar mastodon berserker shield-maiden)
    @wandering_foes = %w(golem cannibal bloodspeaker wendigo)

    def self.before_main
      _gorget = GameObj.inv.find {|i| i.name.eql?("gorget")}
      #fput "rub #%s" % gorget.id unless gorget.nil?
    end

    def self.before_teardown
      return unless defined?(Teleport)
      slot = Teleport::Anchors.find {|anchor| anchor.room.id.eql?(29881)}
      return if slot.nil?
      Script.run("teleport", "%s" % slot.position)
      #Script.run("teleport", "4") if Teleport.teleporter.name
    end
  end
end