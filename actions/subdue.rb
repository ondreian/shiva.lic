module Shiva
  class Subdue < Action
    def priority
      89
    end

    def available?(foe)
      Char.prof.eql?("Rogue") and
      checkstamina > 20 and
      hidden? and
      foe.status.empty? and
      not foe.tall? and
      rand > 0.2
    end

    def subdue(foe)
      Log.out(foe, label: %i(subdue))
      Stance.offensive
      dothistimeout "subdue #%s" % foe.id, 1, Regexp.union(
        %r[You spring from hiding],
        %r[wait]
      )
      Timer.await() if checkrt > 6
    end

    def apply(foe)
      return self.subdue foe
    end
  end
end