module Shiva
  class GuidingStrike < Action
    def priority
      6
    end

    def should?(foe)
      return false if Effects::Debuffs.active?("Silenced")
      return false if Spell[506].known?
      return false if %i(duskruin).include? self.env.name
      return false unless foe.status.empty?
      return false if %i(escort bandits).include?(Bounty.type)
      return true if %w(shaper master).include?(foe.noun)
      return true if percentmana > 90
      return true if Room.current.location.eql?("the Hinterwilds") and foe.nil?
      return false
    end

    def active?
      Effects::Buffs.active?("Spirit Strike") or Spell[117].active?
    end

    def available?(foe)
      Spell[117].known? and
      not self.active? and
      percentmana > 20 and
      Char.prof.eql?("Rogue") and
      self.should?(foe) and
      not hidden? and
      Group.empty?
    end

    def apply()
      _result = dothistimeout "incant 117", 3, Regexp.union(
        %r{An invisible force guides you}
      )
      ttl = Time.now + 1
      wait_until {self.active? or Time.now > ttl}
    end
  end
end