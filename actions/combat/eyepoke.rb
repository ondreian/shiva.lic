module Shiva
  class Eyepoke < Action
    Poked ||= []

    def priority
      4
    end

    def cost
      return 0 if Effects::Buffs.active?("Stamina Second Wind")
      return 7
    end

    def available?(foe)
      CMan.eyepoke > 3 and
      Skills.stalkingandhiding > (Char.level * 2) and
      checkstamina > self.cost * 2 and
      not hidden? and
      not Poked.include?(foe.id) and
      %w(ursian).include?(foe.noun)
    end

    def eyepoke(foe)
      #Log.out(foe, label: %i(eyepoke))
      Stance.offensive
      result = dothistimeout "cman eyepoke #%s" % foe.id, 1, Regexp.union(
        %r[temporarily blinded!],
        %r[wait]
      )
      Poked << foe.id if result =~ %r[temporarily blinded!]
      Poked.shift while Poked.size > 10
      sleep 0.5
      Timer.await() if checkrt > 6
    end

    def apply(foe)
      return self.eyepoke foe
    end
  end
end