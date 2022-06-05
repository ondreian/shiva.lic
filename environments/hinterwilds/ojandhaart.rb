module Shiva
  Environment.define :ojandhaart do
    @entry      = 29902
    @boundaries = %w(30115 29900)
    @town       = %[Hinterwilds]
    @scripts    = %w(reaction lte effect-watcher)
    @foes       = %w(
        wendigo warg skald hinterboar bloodspeaker
        golem mastodon berserker shield-maiden cannibal
      )

    def self.before_main
      _gorget = GameObj.inv.find {|i| i.name.eql?("gorget")}
      #fput "rub #%s" % gorget.id unless gorget.nil?
    end

    def self.before_teardown
      Script.run("ring", "4") if defined? Ring and Ring.exists?
    end
  end
end