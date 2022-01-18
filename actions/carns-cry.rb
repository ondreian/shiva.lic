module Shiva
  class CarnsCry < Action
    def priority
      (70..80).to_a.sample
    end

    def available?(foe)
      Char.prof.eql?("Warrior") and
      checkstamina > 50 and
      @env.foes.size > 1 and
      not foe.nil? and
      foe.status.empty?
    end

    def carns_cry()
      Timer.await()
      fput "warcry cry all"
    end

    def apply(foe)
      return self.carns_cry
    end
  end
end