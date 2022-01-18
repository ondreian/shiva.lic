module Shiva
  class EarthenFury < Action
    def priority
      90
    end

    def available?(foe)
      not foe.nil? and
      not @env.seen.include?(foe.id) and
      not foe.name.include?("Vvrael") and
      Spell[917].known? and
      Spell[917].affordable? and
      checkmana > 20 and
      Wounds.nsys < 2
    end

    def apply(foe)
      Stance.guarded
      @env.seen << foe.id
      fput "target #%s\rincant 917" % foe.id
      if Spell[515].active?
        sleep 0.5
      else
        waitcastrt?
      end
    end
  end
end