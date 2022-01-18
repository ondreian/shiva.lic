module Shiva
  class SpiritSlayer < Action
    def priority
      8
    end

    def available?(foe)
      foe.nil? and
      Spell[240].known? and
      percentmana > 60 and
      not Spell[240].active? and
      Group.size < 3
    end

    def apply(foe)
      waitcastrt?
      fput "incant 240"
    end
  end
end