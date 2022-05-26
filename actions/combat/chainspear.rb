module Shiva
  class Chainspear < Action
    DEFAULT_AIMING = %i(right_eye left_eye neck back)

    def aiming(foe)
      return %i(head neck back) if %w(crab).include?(foe.noun)
      return DEFAULT_AIMING
    end

    def priority
      90
    end

    def holding_chainspear?
      Char.right.name.eql?("razern spear") or
      Char.right.noun.eql?("shaft")
    end

    def available?
      Skills.thrownweapons > Char.level and
      Skills.polearmweapons > Char.level and
      self.holding_chainspear? and
      self.env.foes.size > 0
    end

    def retract_chainspear(n = 1)
      #Log.out([GameObj.right_hand], label: :chain_spear?) if Hunting.chain_spear?
      return unless Char.right.noun.eql?("shaft")
      result = dothistimeout("pull ##{Char.right.id}", 3, /You deftly pull back on/)
      Timer.await()
      self.retract_chainspear(n + 1) if result.nil? and n < 3
    end

    def hurl(foe)
      self.retract_chainspear
      Stance.offensive
      return if foe.dead? or foe.gone?
      foe.hurl()
      Char.aim foe.kill_shot self.aiming(foe) unless foe.dead? or foe.gone?
      self.retract_chainspear
      Timer.await()
    end

    def apply(foe)
      return self.hurl foe
    end
  end
end