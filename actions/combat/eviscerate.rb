module Shiva
  class Eviscerate < Action
    Immune = %w(cerebralite)

    def priority(foe)
      50
    end

    def available?(foe)
      not foe.nil? and
      not self.env.seen.include?(foe.id) and
      not foe.status.empty? and
      self.env.foes.size > 1 and
      not foe.tall? and
      not Immune.include?(foe.noun) and
      CMan.eviscerate > 3 and
      checkstamina > 40 and
      hidden? and
      rand > 0.3
    end

    def eviscerate(foe)
      waitrt?
      Stance.offensive
      put "cman eviscerate #%s" % foe.id
      self.env.seen << foe.id
      Timer.await()
    end

    def apply(foe)
      return self.eviscerate foe
    end
  end
end