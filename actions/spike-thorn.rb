module Shiva
  class Spikethorn < Action
    def priority
      9
    end

    def available?(foe)
      not foe.nil? and
      not foe.name.include?("Vvrael") and
      percentmana > 50 and
      Spell[616].known? and
      Spell[616].affordable? and
      foe.status.empty?
    end

    def apply(foe)
      waitrt?
      waitcastrt?
      fput "target #%s\rincant 616" % foe.id
      waitcastrt?
    end
  end
end