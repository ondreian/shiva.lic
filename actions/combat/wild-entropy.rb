module Shiva
  class WildEntropy < Action
    def priority
      (89..91).to_a.sample
    end

    def available?(foe)
      not foe.nil? and
      not foe.name.include?("Vvrael") and
      foe.status.empty? and
      percentmana <= 50 and
      Spell[603].known? and
      Spell[603].affordable?
    end

    def apply(foe)
      waitcastrt?
      waitrt?
      fput "target #%s\rincant 603" % foe.id
      waitcastrt?
    end
  end
end