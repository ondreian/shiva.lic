module Shiva
  Environment.define :moonsedge_castle do
    @entry      = 32468
    @tags = %i(ascension)
    # boundary rooms:
    # 32330 (gate between imt and moonsedge town)
    # 32442 (bridge between moonsedge town and castle)
    # 32443 (portcullis into moonsedge castle)
    @boundaries = %w(32322 32469 32442)
    @town       = %[Icemule Trace]
    @scripts    = %w(reaction)
    @foes       = %w(vampire fiend conjurer ghast dreadsteed grotesque banshee knight)
    @level      = (100..100)

    def self.before_main
      #gorget = GameObj.inv.find {|i| i.name.eql?("gorget")}
      #fput "rub #%s" % gorget.id unless gorget.nil?
    end

    def self.before_teardown
      Rally.group(Base.closest) if Group.leader? and not Group.empty?
      Teleport.teleport(1) if defined?(Teleport) && Teleport.teleporter
    end
  end
end