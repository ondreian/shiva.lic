module Shiva
  class Kill < Action
    def priority
      101
    end

    def available?(foe)
      not foe.nil? and
      self.env.foes.size > 0 and
      (Tactic.edged? or Tactic.polearms?) and 
      Lich::Claim.mine?
    end

    def get_best_area(foe)
      proposed_area = foe.kill_shot Aiming.lookup(foe)
      Log.out("{foe=%s, aim=%s}" % [foe.name, @area])
      @area = proposed_area
      return @area
    end

    def kill(foe)
      Stance.offensive
      if Skills.ambush < 25 || (foe.tall? && !foe.status.include?(:prone)) || foe.name =~ /spectral|ethereal|triton protector|fallen crusader/
        put "attack #%s clear" % foe.id
      else
        area = self.get_best_area(foe)
        area = "clear" if %w(chest back).include?(area.to_s)
        put "attack #%s %s" % [foe.id, area]
      end
      Timer.await()
    end

    def apply(foe)
      return self.kill foe
    end
  end
end