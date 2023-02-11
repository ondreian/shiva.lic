module Shiva
  Environment.define :ojandhaart do
    @entry      = 29902
    @level      = (100..100)
    @boundaries = %w(30115 29900)
    @town       = %[Hinterwilds]
    @scripts    = %w(reaction lte effect-watcher)
    @foes       = %w(warg skald hinterboar mastodon berserker shield-maiden)
    @wandering_foes = %w(golem cannibal bloodspeaker wendigo)

    def self.before_main
      _gorget = GameObj.inv.find {|i| i.name.eql?("gorget")}
      #fput "rub #%s" % gorget.id unless gorget.nil?
    end

    def self.before_teardown
      Script.run("ring", "4") if defined? Ring and Ring.exists?
    end
  end
end