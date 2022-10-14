module Shiva
  class BoneShatter < Action
    def priority
      9
    end

    def available?(foe)
      not foe.nil? and
      not foe.name.include?("Vvrael") and
      not foe.name =~ /spectral|ethereal|protector/ and
      
      Spell[1106].known? and
      Spell[1106].affordable?
    end

    def apply(foe)
      fput "target #%s\rincant 1106" % foe.id
      waitcastrt?
    end
  end
end