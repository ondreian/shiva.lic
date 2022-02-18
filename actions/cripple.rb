module Shiva
  class Cripple < Action
    Nouns = %w(destroyer master)
    Seen  = []

    def priority
      6
    end

    def available?(foe)
      Nouns.include?(foe.noun) and
      Char.prof.eql?("Rogue") and
      foe.status.empty? and
      Seen.count(foe.id) < 2 and
      checkstamina > 20 and
      not hidden? and
      foe.status.empty? and
      not foe.tall? and
      rand > 0.2
    end

    def cripple(foe)
      Stance.offensive
      outcome = dothistimeout "weapon cripple #%s right leg" % foe.id, 1, Regexp.union(
        %r[You sidle in close and drag the blade across the back],
      )
      Seen << foe.id if outcome =~ %r[You sidle in close and drag the blade across the back]
      Timer.await() if checkrt > 6
    end

    def apply(foe)
      return self.cripple foe
    end
  end
end