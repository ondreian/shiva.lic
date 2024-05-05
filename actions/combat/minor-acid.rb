module Shiva
  class MinorAcid < Action
    def priority
      1_000 #(85...95).to_a.sample
    end

    def high_ds?(noun)
      %w(shaper master).include?(noun)
    end

    def available?(foe)
      Lich::Claim.mine? and
      not foe.nil? and
      not foe.name.include?("Vvrael") and
      not self.high_ds?(foe.noun) and
      Spell[904].known? and
      Spell[904].affordable? and
      checkmana > 20 and
      Wounds.nsys < 2
    end

    def apply(foe)
      fput "stance off\rincant 904\rstance guard" % foe.id
      if Spell[515].active?
        sleep 0.5
      else
        waitcastrt?
      end
    end
  end
end