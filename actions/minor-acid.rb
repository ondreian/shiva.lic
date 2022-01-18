module Shiva
  class MinorAcid < Action
    def priority
      (85...95).to_a.sample
    end

    def available?(foe)
      not foe.nil? and
      not foe.name.include?("Vvrael") and
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