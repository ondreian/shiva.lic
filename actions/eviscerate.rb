module Shiva
  class Eviscerate < Action
    def priority(foe)
      50
    end

    def available?(foe)
      not foe.nil? and
      not @env.seen.include?(foe.id) and
      not foe.status.empty? and
      (@env.foes.size > 1 or %w(master).include?(foe.noun)) and
      not foe.tall? and
      not %w(cerebralite).include?(foe.noun) and
      CMan.eviscerate > 3 and
      checkstamina > 40 and
      hidden? and
      rand > 0.3
    end

    def eviscerate(foe)
      waitrt?
      Stance.offensive
      put "cman eviscerate #%s" % foe.id
      @env.seen << foe.id
      Timer.await()
    end

    def apply(foe)
      return self.eviscerate foe
    end
  end
end