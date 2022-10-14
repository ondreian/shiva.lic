module Shiva
  class GuidingStrike < Action
    def priority
      6
    end

    def should?(foe)
      return true if %w(shaper master).include?(foe.noun)
      return true if percentmana > 90
      return true if Room.current.location.eql?("the Hinterwilds") and foe.nil?
      return false
    end

    def available?(foe)
      Spell[117].known? and
      percentmana > 20 and
      Char.prof.eql?("Rogue") and
      not Spell[117].active? and
      self.should?(foe) and
      not hidden? and
      Group.empty?
    end

    def apply()
      Spell[117].cast
      Char.hide if Skills.stalkingandhiding > Char.level and not hidden? and not invisible?
    end
  end
end