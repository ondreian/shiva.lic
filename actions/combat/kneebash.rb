module Shiva
  class Kneebash < Action
    Immune = %w(
      crawler cerebralite worm banshee 
      conjurer undansormr angargeist 
      ooze oozeling disir
    )

    Cooldown = {

    }

    def priority
      6
    end

    def cost
      Effects::Buffs.active?("Stamina Second Wind") ? 0 : 8
    end

    def not_cooldown?(foe)
      return true if Cooldown[foe.id].nil?
      Cooldown[foe.id] < Time.now
    end

    def available?(foe)
      CMan.kneebash > 2 and
      not muckled? and
      checkstamina > (self.cost * 3) and
      foe.status.include?(:flying) and
      not Immune.include?(foe.noun) and
      self.not_cooldown?(foe)
    end

    def kneebash(foe)
      Log.out("status=%s" % foe.status)
      Stance.offensive
      result = dothistimeout "cheapshot kneebash #%s" % foe.id, 1, Regexp.union(
        %r[ swing the blunt end down at the knee of],
        %r[wait]
      )
      if result =~ /swing the blunt end/
        Cooldown[foe.id] = Time.now + 6
      end
      sleep 0.5
      Timer.await() if checkrt > 6
    end

    def apply(foe)
      return self.kneebash foe
    end
  end
end