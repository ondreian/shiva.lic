module Shiva
  class Hamstring < Action
    Immune = %w(crawler cerebralite siphon worm)

    def priority
      5
    end

    def cost
      Effects::Buffs.active?("Stamina Second Wind") ? 0 : 9
    end

    def available?(foe)
      CMan.hamstring > 2 and
      Tactic.edged? and
      not hidden? and
      not Effects::Debuffs.active?("Jaws") and
      checkstamina > (self.cost * 6) and
      ((foe.tall? and foe.status.empty?) or (not hidden? and foe.status.empty? and percentstamina > 80)) and
      not Immune.include?(foe.noun)
    end

    def hamstring(foe)
      Stance.offensive
      dothistimeout "cman hamstring #%s" % foe.id, 1, Regexp.union(
        %r[You lunge forward and try to hamstring],
        %r[wait]
      )
      sleep 0.5
      Timer.await() if checkrt > 6
    end

    def apply(foe)
      return self.hamstring foe
    end
  end
end