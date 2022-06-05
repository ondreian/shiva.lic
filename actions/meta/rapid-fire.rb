module Shiva
  class RapidFire < Action
    def priority
      Priority.get(:medium)
    end

    def available?
      Spell[515].known? and
      Spell[515].affordable? and
      not Spell[515].active? and
      Group.empty?
    end

    def apply()
      fput "incant 515"
      waitcastrt?
    end
  end
end