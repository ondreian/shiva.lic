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
      %w(shaper master).include?(foe.noun) and
      Group.empty?
    end

    def apply()
      Spell[117].cast
      #waitcastrt?
    end
  end
end