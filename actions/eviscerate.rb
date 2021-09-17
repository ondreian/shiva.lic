module Shiva
  class Eviscerate < Action
    def priority
      [89, 91].sample
    end

    def available?(foe)
      not foe.nil? and
      not @env.seen.include?(foe.id) and
      @env.foes.size > 1 and
      not foe.tall? and
      Char.name.eql?("Ondreian") and
      not Effects::Cooldowns.active?("Cyclone") and
      checkstamina > 40 and
      hidden? and
      rand > 0.3
    end

    def eviscerate(foe)
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