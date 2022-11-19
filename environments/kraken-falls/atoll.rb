module Shiva
  Environment.define :atoll do
    @entry      = 30816
    @town       = %[Kraken's Fall]
    @scripts    = %w(reaction lte effect-watcher)
    @foes       = %w(brawler warlock protector assassin)
    @boundaries = %w(30815)
    @divergence = true

    def self.before_main
      Stance.defensive
    end

    def self.before_teardown
      Voln.fog
      Base.go2
      Char.unarm
      #Script.run("eloot", "sell")
    end
  end
end