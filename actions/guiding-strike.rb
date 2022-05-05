module Shiva
  class GuidingStrike < Action
    def priority
      5
    end

    def available?(foe)
      Spell[117].known? and
      percentmana > 20 and
      Char.prof.eql?("Rogue") and
      not Spell[117].active? and
      not hidden? and
      (%w(shaper master).include?(foe.noun) or percentmana > 100) and
      Group.empty?
    end

    def apply()
      Spell[117].cast
      Char.hide if Skills.stalkingandhiding > Char.level
    end
  end
end