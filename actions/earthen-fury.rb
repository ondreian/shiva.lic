module Shiva
  class EarthenFury < Action
    def priority
      90
    end

    def available?(foe)
      not foe.nil? and
      not @env.seen.include?(foe.id) and
      Spell[917].known? and
      Spell[917].affordable?
    end

    def apply(foe)
      Stance.guarded
      @env.seen << foe.id
      fput "target #%s\rincant 917" % foe.id
      waitcastrt? unless Spell[515].active?
    end
  end
end