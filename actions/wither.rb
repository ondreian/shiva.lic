module Shiva
  class Wither < Action
    def priority
      10
    end

    def available?(foe)
      not foe.nil? and
      not foe.name.include?("Vvrael") and
      Spell[1115].known? and
      Spell[1115].affordable?
    end

    def apply(foe)
      fput "target #%s\rincant 1115" % foe.id
      waitcastrt?
    end
  end
end