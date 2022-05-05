module Shiva
  class Sweep < Action
    Immune = %w(crawler cerebralite)

    def priority
      (40..60).to_a.sample
    end

    def cost
      8
    end

    def available?(foe)
      Char.prof.eql?("Rogue") and
      checkstamina > self.cost and
      not hidden? and
      foe.status.empty? and
      not Immune.include?(foe.noun)
    end

    def sweep(foe)
      Stance.offensive
      dothistimeout "sweep #%s" % foe.id, 1, Regexp.union(
        %r[You spring from hiding],
        %r[wait]
      )
      sleep 0.5
      Timer.await() if checkrt > 6
    end

    def apply(foe)
      return self.sweep foe
    end
  end
end