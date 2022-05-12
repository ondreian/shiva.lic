module Shiva
  class Cutthroat < Action
    Cutthroat = []
    Nouns     = %w(shaper master siphon)

    def priority
      61
    end

    def cost
      Effects::Buffs.active?("Shadow Dance") ? 0 : 20
    end

    def available?(foe)
      Char.prof.eql?("Rogue") and
      not self.env.name.eql?(:duskruin) and
      checkstamina > self.cost and
      hidden? and
      not Cutthroat.include?(foe.id) and
      Nouns.include?(foe.noun)
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