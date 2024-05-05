module Shiva
  Environment.define :moonsedge_village do
    @entry      = 32373
    # boundary rooms: 
    # 32330 (gate between imt and moonsedge town)
    # 32442 (bridge between moonsedge town and castle)
    # 32443 (portcullis into moonsedge castle)
    @boundaries = %w(32330 32442) # + %w(32423)
    @town       = %[Icemule Trace]
    @scripts    = %w(reaction)
    @foes       = %w(dreadsteed grotesque ghast banshee knight)
    @wandering_foes = %w(vampire fiend conjurer)
    @level      = (100..100)

    def self.before_main
      #gorget = GameObj.inv.find {|i| i.name.eql?("gorget")}
      #fput "rub #%s" % gorget.id unless gorget.nil?
    end

    def self.before_teardown
      Teleport.teleport(1) if defined?(Teleport) && Teleport.teleporter
    end
  end
end