module Shiva
  class Hide < Action
    PERCEPTIVE = %w(ursian lion griffin)
    Deny = %w(4212003)

    class Outcomes
      Deny = %r{You look around, but can't see anywhere to hide.}
      Ok   = %r{You attempt to blend with the surroundings,}
      All  = Regexp.union(Deny)
    end

    def priority
      if @env.foes.any? {|foe| PERCEPTIVE.include?(foe.noun) }
        1_000
      else
        5
      end
    end

    def env?
      return false if Group.leader? and not Group.empty?
      return false if @env.name.eql?("Bandits") and not Group.empty?
      return false if @env.name.eql?("Osa")
      return @env.foes.size > 0 if @env.name.eql?("Bandits")
      return true
    end

    def available?
      Skills.stalkingandhiding > (Char.level * 2) and
      not Effects::Debuffs.active?("Jaws") and
      not hidden? and
      not Opts["open"] and
      env? and 
      not Deny.include?(XMLData.room_id.to_s)
    end

    def apply()
      Timer.await()
      case dothistimeout("hide", 2, Outcomes::All)
      when Outcomes::Deny
        Deny << XMLData.room_id.to_s
      end
    end
  end
end