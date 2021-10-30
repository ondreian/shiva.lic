module Shiva
  class MinorAcid < Action
    def priority
      (85...95).to_a.sample
    end

    def available?(foe)
      not foe.nil? and
      Spell[904].known? and
      Spell[904].affordable?
    end

    def apply(foe)
      fput "stance off\rincant 904\rstance guard" % foe.id
      waitcastrt? unless Spell[515].active?
    end
  end
end