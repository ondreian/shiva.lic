module Shiva
  class Cripple < Action
    Immune = %w(crawler cerebralite)
    Seen  = []

    def priority
      (40..60).to_a.sample
    end

    def cost
      Effects::Buffs.active?("Stamina Second Wind") ? 0 : 7
    end

    def available?(foe)
      not Immune.include?(foe.noun) and
      Weapon.cripple > 3 and
      not Effects::Buffs.active?("Shadow Dance") and
      foe.status.empty? and
      Seen.count(foe.id) < 2 and
      checkstamina > (self.cost * 3) and
      not hidden? and
      foe.status.empty? and
      rand > 0.2
    end

    def cripple(foe)
      Stance.offensive
      outcome = dothistimeout "weapon cripple #%s leg" % foe.id, 1, Regexp.union(
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