module Shiva
  class Sunburst < Action
    def priority
      (89..91).to_a.sample
    end

    def available?(foe)
      not foe.nil? and
      not foe.name.include?("Vvrael") and
      foe.status.empty? and
      Spell[609].known? and
      Spell[609].affordable?
    end

    def apply(foe)
      waitcastrt?
      waitrt?
      fput "target #%s\rincant 609" % foe.id
      waitcastrt?
    end
  end
end