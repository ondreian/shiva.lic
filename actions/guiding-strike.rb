module Shiva
  class GuidingStrike < Action
    def priority
      5
    end

    def available?(foe)
      Spell[117].known? and
      percentmana > 50 and
      Char.prof.eql?("Rogue") and
      not Spell[117].active? and
      not hidden? and
      (@env.foes.size == 0 or %w(master).include?(foe.noun))
    end

    def apply()
      Spell[117].cast
      #waitcastrt?
    end
  end
end