module Shiva
  class Condemn < Action
    def priority
      90
    end

    def available?(foe)
      not foe.nil? and
      not foe.name.include?("Vvrael") and
      Spell[309].known? and
      Spell[309].affordable? and
      Wounds.nsys < 2
    end

    def apply(foe)
      Stance.guarded
      fput "target #%s\rincant 309\rstance guard" % foe.id
      waitcastrt? unless Spell[515].active?
    end
  end
end