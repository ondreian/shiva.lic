module Shiva
  class GuardantThruster < Action
    def priority
      rand > 0.5 ? 6 : 40
    end

    def available?(foe)
      not foe.nil? and
      self.env.foes.size < 2 and
      not Effects::Cooldowns.active?("Guardant Thrusts") and
      Tactic.polearms? and
      foe.name =~ /spectral|ethereal|protector/ and
      checkstamina > 50 and
      not hidden?
    end

    def await_result(foe)
      while line=get
        break if line.start_with?("...wait")
        break if line.include?("You complete your assault")
        break if line.include?("Distracted, you hesitate, and in doing so lose the rhythm of your assault.")
        break unless GameObj[foe.id]
        break if foe.dead?
      end
    end

    def guardant_thrusts(foe)
      Script.pause("reaction")
      waitrt?
      Stance.offensive
      matched = dothistimeout "weapon gthrust #%s" % foe.id, 2, /Retaining a defensive profile, you raise your/ 
      self.await_result(foe) if matched
      Script.unpause("reaction")
    end

    def apply(foe)
      return self.guardant_thrusts foe
    end
  end
end