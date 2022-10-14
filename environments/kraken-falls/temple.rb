module Shiva
  Environment.define :atolltemple do
    @entry      = 30851
    @town       = %[Kraken's Fall]
    @scripts    = %w(reaction lte effect-watcher)
    @foes       = %w(psionicist fanatic warden)
    @boundaries = %w(30850)
    @divergence = true

    def self.before_main
      Stance.defensive
    end

    def self.before_teardown
      Voln.fog
      Teardown.new(self).return_to_base
      Char.unarm
      #Script.run("eloot", "sell")
    end
  end
end