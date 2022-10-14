module Shiva
  class Feint < Action
    def priority
      4
    end

    def available?(foe)
      not foe.nil? and
      not self.env.seen.include?(foe.id) and
      CMan.feint > 3 and
      checkstamina > 20
    end

    def feint(foe)
      Timer.await() if checkrt > 5
      Stance.offensive
      fput "cman feint #%s" % foe.id
    end

    def apply(foe)
      self.feint foe
      self.env.seen << foe.id
    end
  end
end