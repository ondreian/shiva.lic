module Shiva
  class Cutthroat < Action
    Cutthroat = []
    Immune    = %w(crawler cerebralite golem hinterboar)

    def priority
      61
    end

    def cost
      return 0 if Effects::Buffs.active?("Shadow Dance")
      return 0 if Effects::Buffs.active?("Stamina Second Wind")
      return 20
    end

    def reachable?(foe)
      not foe.tall? or foe.prone? or foe.status.include?(:frozen)
    end

    def available?(foe)
      Char.prof.eql?("Rogue") and
      not self.env.name.eql?(:duskruin) and
      checkstamina > self.cost and
      hidden? and
      not Cutthroat.include?(foe.id) and
      self.reachable?(foe) and
      not Immune.include?(foe.noun)
    end

    def cutthroat(foe)
      #Log.out(foe, label: %i(cutthroat))
      Stance.offensive
      result = dothistimeout "cman cutthroat #%s" % foe.id, 1, Regexp.union(
        %r[You slice deep into],
        %r[wait]
      )
      Cutthroat << foe.id if result =~ %r[You slice deep into]
      sleep 0.5
      Timer.await() if checkrt > 6
    end

    def apply(foe)
      return self.cutthroat foe
    end
  end
end