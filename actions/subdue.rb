module Shiva
  class Subdue < Action
    def priority
      60
    end

    def cost
      Effects::Buffs.active?("Shadow Dance") ? 0 : 20
    end

    def can?(foe)
      return true if not foe.tall? and foe.status.empty?
      return true if foe.tall? and foe.prone?
      return false
    end

    def available?(foe)
      CMan.subdue > 2 and
      not self.env.name.eql?(:duskruin) and
      checkstamina > self.cost and
      hidden? and
      self.can?(foe) and
      not Spell[1035].active? and
      rand > 0.2
    end

    def subdue(foe)
      #Log.out(foe, label: %i(subdue))
      Stance.offensive
      result = dothistimeout "subdue #%s" % foe.id, 1, Regexp.union(
        %r[You spring from hiding],
        %r[head is out of reach!],
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