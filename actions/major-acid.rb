module Shiva
  class EarthenFury < Action
    def priority
      90
    end

    def available?(foe)
      not foe.nil? and
      Spell[917].known? and
      Spell[917].affordable?
    end

    def apply(foe)
      Stance.guarded
      fput "target #%s\rincant 917" % foe.id
      waitcastrt?
    end
  end
end