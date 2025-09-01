module Shiva
  Environment.define :hive do
    @entry      = 34192
    @town       = %[Zul]
    @scripts    = %w(reaction)
    @foes       = %w(thrall myrmidon)
    @boundaries = %w(34170 34211)
    @divergence = true
    @level      = (100..100)

    def self.before_main
      Stance.defensive
      Boost.loot
    end

    def self.before_teardown
      #Voln.fog
      Base.go2
      #Char.unarm
      #Script.run("eloot", "sell")
    end
  end
end