module Shiva
  class Kill < Action
    def priority
      101
    end

    def available?(foe)
      not foe.nil? and
      self.env.foes.size > 0 and
      (Tactic.edged? or Tactic.polearms?) and 
      Claim.mine?
    end

    def kill(foe)
      Stance.offensive
      if Skills.ambush < 25 || (foe.tall? && !foe.status.include?(:prone)) || foe.name =~ /spectral|ethereal|triton protector/
        put "attack #%s clear" % foe.id
      else
        put "attack #%s head" % foe.id
      end
      Timer.await()
    end

    def apply(foe)
      return self.kill foe
    end
  end
end