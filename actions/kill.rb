module Shiva
  class Kill < Action
    def priority
      101
    end

    def has_melee_skill?
      Skills.polearmweapons > Char.level * 1.5 or
      Skills.edgedweapons > Char.level * 1.5
    end

    def available?(foe)
      not foe.nil? and
      @env.foes.size > 0 and
      self.has_melee_skill?
    end

    def kill(foe)
      Stance.offensive
      put "kill #%s" % foe.id
      Timer.await()
    end

    def apply(foe)
      return self.kill foe
    end
  end
end