module Shiva
  class Headbutt < Action
    Nouns = %w(siphon crawler lich)
    Seen  = []

    def priority
      3
    end

    def available?(foe)
      Nouns.include?(foe.noun) and
      CMan.headbutt > 0 and
      foe.status.empty? and
      Seen.count(foe.id) < 2 and
      checkstamina > 20 and
      not hidden? and
      foe.status.empty? and
      not foe.tall? and
      rand > 0.1
    end

    def headbutt(foe)
      Stance.offensive
      outcome = dothistimeout "cman headbutt #%s" % foe.id, 1, Regexp.union(
        %r[You slam your head into],
        %r[deftly avoids your headbutt],
        %r[wait],
        %r[is already suffering from massive head wounds]
      )
      Seen << foe.id if outcome =~ %r[You slam your head into|is already suffering from massive head wounds]
      Timer.await() if checkrt > 6
    end

    def apply(foe)
      return self.headbutt foe
    end
  end
end