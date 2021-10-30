module Shiva
  class RapidFire < Action
    def priority
      5
    end

    def available?
      Spell[515].known? and
      Spell[515].affordable? and
      not Spell[515].active?
    end

    def apply()
      fput "incant 515"
      waitcastrt?
    end
  end
end