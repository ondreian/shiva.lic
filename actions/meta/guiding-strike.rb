module Shiva
  class GuidingStrike < Action
    def priority
      5
    end

    def should?(foe)
      return true if %w(shaper master).include?(foe.noun)
      return true if percentmana > 100
      return true if Room.current.location.eql?("the Hinterwilds") and foe.nil?
      return false
    end

    def available?(foe)
      Spell[117].known? and
      percentmana > 20 and
      Char.prof.eql?("Rogue") and
      not Spell[117].active? and
      not hidden? and
      self.should?(foe) and
      Group.empty?
    end

    def apply()
      Spell[117].cast
      Char.hide if Skills.stalkingandhiding > Char.level
    end
  end
end