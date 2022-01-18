module Shiva
  class Mug < Action
    Mugged = []

    def priority(foe)
      50
    end

    def available?(foe)
      not foe.nil? and
      not Mugged.include?(foe.id) and
      not foe.status.empty? and
      Char.name.eql?("Ondreian") and
      checkstamina > 40 and
      hidden? and
      rand > 0.1
    end

    def mug(foe)
      waitrt?
      Stance.offensive
      put "cman mug #%s" % foe.id
      Mugged << foe.id
      sleep 0.5
      Timer.await()
    end

    def apply(foe)
      waitrt?
      return self.mug foe
    end
  end
end