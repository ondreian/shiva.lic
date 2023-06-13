module Shiva
  class Sweep < Action
    Immune = %w(crawler cerebralite worm)

    def priority
      6
    end

    def cost
      Effects::Buffs.active?("Stamina Second Wind") ? 0 : 8
    end

    def available?(foe)
      CMan.sweep > 2 and
      not Effects::Debuffs.active?("Jaws") and
      not hidden? and
      checkstamina > (self.cost * 3) and
      ((foe.tall? and foe.status.empty?) or (not hidden? and foe.status.empty?)) and
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