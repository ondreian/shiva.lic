module Shiva
  class Ambush < Action
    DEFAULT_AIMING = %i(head neck right_leg)
    SPEAR_AIMING   = %i(left_eye right_eye head neck)

    def priority
      91
    end

    def has_melee_skill?
      Skills.polearmweapons > Char.level * 1.5 or
      Skills.edgedweapons > Char.level * 1.5
    end

    def available?(foe)
      self.has_melee_skill? and
      Skills.ambush > 24 and
      not foe.nil? and
      not foe.tall?
    end

    Outcomes = Regexp.union(
      /^You (swing|thrust|throw)/,
      /You cannot aim/,
      %r[is already dead],
      %r[What were you referring to],
    )

    def aiming
      return SPEAR_AIMING if %w(spear harpoon).include?(Char.right.noun)
      return DEFAULT_AIMING
    end

    def ambush(creature)
      Stance.offensive
      result = dothistimeout("ambush ##{creature.id}", 1, Outcomes)
      return self.kill(creature) if result =~ /You cannot aim/
      # look and parse the next best killshot while in roundtime
      unless creature.dead?
        Char.aim(
          creature.kill_shot(self.aiming))
      end
      Timer.await
    end

    def kill(creature)
      Stance.offensive
      dothistimeout("kill ##{creature.id}", 1, Outcomes)
      Timer.await
    end

    def apply(foe)
      return self.ambush foe
    end
  end
end