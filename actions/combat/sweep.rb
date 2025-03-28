module Shiva
  class Sweep < Action
    Immune = %w(crawler cerebralite worm banshee conjurer undansormr angargeist ooze oozeling disir siren elemental)

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
      result = dothistimeout "sweep #%s" % foe.id, 1, Regexp.union(
        %r[You spring from hiding],
        %r{You cannot sweep},
        %r[wait],
      )
      if result =~ %r{You cannot sweep}
        Immune << foe.noun
      end
      sleep 0.5
      Timer.await() if checkrt > 6
    end

    def apply(foe)
      return self.sweep foe
    end
  end
end