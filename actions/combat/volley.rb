module Shiva
  class Volley < Action
    def priority
      50
    end

    def cost
      20
    end

    def skilled?
      Tactic.can?(:rangedweapons)
    end

    def bow
      Containers.harness.where(noun: %`bow`).first
    end

    def available?(foe)
      self.env.foes.size > 3 and
      not Effects::Cooldowns.active?("Volley") and
      checkstamina > self.cost and
      (Tactic.ranged? or (self.skilled? and not bow.nil?))
    end

    def apply(foe)
      return fput "weapon volley" if Tactic.ranged?
      Hand.both {
        bow = self.bow
        bow.take
        dothistimeout("weapon volley", 2, %r`you loose arrow after arrow as fast as you can`)
        sleep 1
        waitrt?
        Containers.harness.add(Char.left)
      }
    end
  end
end