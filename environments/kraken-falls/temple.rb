module Shiva
  Environment.define :atoll_temple do
    @entry      = 30851
    @town       = %[Kraken's Fall]
    @scripts    = %w(reaction lte effect-watcher)
    @foes       = %w(psionicist fanatic warden)
    @boundaries = %w(30850)
    @divergence = true
    @level      = (100..100)

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