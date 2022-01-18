module Shiva
  class Divert < Action
    def priority(foe)
      7
    end

    def available?(foe)
      not foe.nil? and
      @env.foes.size > 2 and
      foe.status.empty? and
      Char.name.eql?("Ondreian") and
      checkstamina > 20 and
      hidden?
    end

    def divert(foe)
      waitrt?
      Stance.offensive
      put "cman divert %s sneak" % foe.noun
      @env.seen << foe.id
      sleep 0.5
      waitrt?
    end

    def apply(foe)
      return self.divert foe
    end
  end
end