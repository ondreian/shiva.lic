module Shiva
  class GuidingStrike < Action
    def priority
      6
    end

    def should?(foe)
      return true if Room.current.location.eql?("the Hinterwilds") and foe.nil? and percentmana > 60
      return false if Effects::Debuffs.active?("Silenced")
      return false if %i(duskruin).include? self.env.name
      return true if %w(valravn).include?(foe.noun) and foe.status.include?(:flying)
      return false unless foe.status.empty?
      return false if %i(escort bandits).include?(Bounty.type)
      return false if Spell[506].known?
      return true if %w(shaper master valravn).include?(foe.noun)
      return true if percentmana > 90
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
      #not hidden? and
      Group.empty?
    end

    def apply()
      _result = dothistimeout "incant 117", 3, Regexp.union(
        %r{An invisible force guides you}
      )
      fput "hide" if Skills.stalking_and_hiding > Char.level * 2
      ttl = Time.now + 1
      wait_until {self.active? or Time.now > ttl}
    end
  end
end