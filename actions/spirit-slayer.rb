module Shiva
  class SpiritSlayer < Action
    def priority
      7
    end

    def available?(foe)
      foe.nil? and
      Spell[240].known? and
      percentmana > 30 and
      not Spell[240].active? and
      Group.size < 3 and
      GameObj.targets.to_a.empty?
    end

    def apply(foe)
      waitcastrt?
      Spell[240].cast()
    end
  end
end