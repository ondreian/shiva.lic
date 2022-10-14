module Shiva
  class Barrage < Action
    Beefy = %w(destroyer)

    def priority
      5_000
    end

    def available?(foe)
      Beefy.include?(foe.noun)
      not Effects::Cooldowns.active?("Barrage") and
      Tactic.ranged?
    end

    def apply(foe)
      Timer.await() if checkrt > 5
      Stance.offensive
      fput "weapon barrage #%s" % foe.id
      ttl = Time.now + 5
      while line=get
        break if line.include?("Your satisfying display of dexterity bolsters you and inspires those around you!")
        break unless GameObj[foe.id]
        break if foe.dead? or foe.gone?
        break if Time.now > ttl
      end
    end
  end
end