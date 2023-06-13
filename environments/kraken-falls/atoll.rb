module Shiva
  Environment.define :atoll do
    @entry      = 30816
    @town       = %[Kraken's Fall]
    @scripts    = %w(reaction)
    @foes       = %w(brawler warlock protector assassin)
    @boundaries = %w(30815)
    @divergence = true
    @level      = (95..100)

    def self.before_main
      Stance.defensive
      Boost.loot
    end

    def self.before_teardown
      Voln.fog
      Base.go2
      #Char.unarm
      #Script.run("eloot", "sell")
    end
  end
end