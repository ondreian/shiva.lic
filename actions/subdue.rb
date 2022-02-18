module Shiva
  class Subdue < Action
    def priority
      60
    end

    def available?(foe)
      Char.prof.eql?("Rogue") and
      not @env.namespace.eql?(Duskruin) and
      checkstamina > 20 and
      hidden? and
      foe.status.empty? and
      not foe.tall? and
      not Spell[1035].active? and
      rand > 0.2
    end

    def subdue(foe)
      #Log.out(foe, label: %i(subdue))
      Stance.offensive
      dothistimeout "subdue #%s" % foe.id, 1, Regexp.union(
        %r[You spring from hiding],
        %r[wait]
      )
      sleep 0.5
      Timer.await() if checkrt > 6
    end

    def apply(foe)
      return self.subdue foe
    end
  end
end