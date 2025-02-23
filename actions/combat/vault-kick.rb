module Shiva
  class VaultKick < Action

    Kicked = []

    def priority
      (89...100).to_a.sample
    end

    def available?(foe)
      Wounds.leftLeg < 2 and
      Wounds.rightLeg < 2 and
      not foe.nil? and
      foe.status.empty? and
      CMan.vault_kick and
      not hidden? and
      Tactic.polearms? and
      not Kicked.include?(foe.id) and
      not %w(cerebralite).include?(foe.noun) and
      checkstamina > 30
    end

    def vault(foe)
      Stance.offensive
      fput "cman vault #%s" % foe.id
      Kicked << foe.id
      Timer.await()
    end

    def apply(foe)
      return self.vault foe
    end
  end
end