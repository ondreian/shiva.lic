module Shiva
  class VaultKick < Action
    def priority
      (89...100).to_a.sample
    end

    def available?(foe)
      Wounds.leftLeg < 2 and
      Wounds.rightLeg < 2 and
      not foe.nil? and
      foe.status.empty? and
      Char.name.eql?("Etanamir") and
      checkstamina > 30
    end

    def vault(foe)
      Stance.offensive
      fput "cman vault #%s" % foe.id
      Timer.await()
    end

    def apply(foe)
      return self.vault foe
    end
  end
end