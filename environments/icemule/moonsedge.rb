module Shiva
  Environment.define :moonsedge do
    @entry      = 32373
    @boundaries = %w(32322 32423)
    @town       = %[404] # %[Icemule]
    @scripts    = %w(reaction effect-watcher)
    @foes       = %w(vampire grotesque ghast banshee knight dreadsteed)
    @level      = (100..100)

    def self.before_main
      gorget = GameObj.inv.find {|i| i.name.eql?("gorget")}
      fput "rub #%s" % gorget.id unless gorget.nil?
    end

    def self.before_teardown
      Script.run("ring", "1") if defined? Ring and Ring.exists?
    end
  end
end