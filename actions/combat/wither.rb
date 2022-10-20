module Shiva
  class Wither < Action
    def priority
      10
    end

    def available?(foe)
      not foe.nil? and
      not foe.name.include?("Vvrael") and
      foe.name =~ /spectral|triton protector|ethereal|triton psionicist/ and
      Spell[1115].known? and
      Spell[1115].affordable?
    end

    def apply(foe)
      waitcastrt?
      fput "target #%s\rincant 1115" % foe.id
    end
  end
end