module Shiva
  class Hamstring < Action
    Immune = %w(
      crawler cerebralite siphon worm 
      banshee conjurer angargeist 
      undansormr ooze oozeling 
      elemental siren
    )

    def priority
      5
    end

    def cost
      Effects::Buffs.active?("Stamina Second Wind") ? 0 : 9
    end

    def should?(foe)
      true
    end

    def available?(foe)
      !foe.nil? and
      CMan.hamstring > 2 and
      Tactic.edged? and
      not hidden? and
      foe.status.empty? and
      not foe.type.include?("noncorporeal") and
      !self.env.seen.include?(foe.id) and
      not Effects::Debuffs.active?("Jaws") and
      checkstamina > (self.cost * 6) and
      self.should?(foe) and
      not Immune.include?(foe.noun)
    end

    def hamstring(foe)
      Stance.offensive
      dothistimeout "cman hamstring #%s" % foe.id, 1, Regexp.union(
        %r[You lunge forward and try to hamstring],
        %r[wait]
      )
      self.env.seen << foe.id
      sleep 0.5
      Timer.await() if checkrt > 6
    end

    def apply(foe)
      return self.hamstring foe
    end
  end
end