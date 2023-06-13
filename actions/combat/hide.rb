module Shiva
  class Hide < Action
    PERCEPTIVE_NOUNS = %w(ursian lion griffin)
    Deny = %w(4212003)
    Perceptive = []

    class Outcomes
      Deny = %r{You look around, but can't see anywhere to hide.}
      Ok   = %r{You attempt to blend with the surroundings,}
      Err  = %r{notices your attempt to hide!}
      All  = Regexp.union(Deny, Ok, Err)
    end

    def outside?
      XMLData.room_exits_string.start_with?("Obvious paths")
    end

    def camo?
      !XMLData.room_count.eql?(@lock) &&
      Spell[608].known? && 
      Spell[608].affordable? && 
      self.outside? && 
      checkmana > 50 && 
      self.env.foes.size > 0
    end

    def priority
      return 7 if self.camo?
      return 1_000 if self.env.foes.any? {|foe| PERCEPTIVE_NOUNS.include?(foe.noun) }
      return 7
    end

    def env?
      return false if Group.leader? and not Group.empty?
      return false if self.env.name.eql?(:bandits) and not Group.empty?
      return false if self.env.name.eql?(:osa)
      return self.env.foes.size > 0 if self.env.name.eql?(:bandits)
      return true
    end

    def available?
      Skills.stalkingandhiding > (Char.level * 2) and
      not Effects::Debuffs.active?("Jaws") and
      not invisible? and
      not %i(bandits escort).include?(@env.name) and
      not self.env.foes.any? {|foe| Perceptive.count(foe.id) > 2} and
      not hidden? and
      not Opts["open"] and
      self.env? and
      not Wounds.head > 1 and
      not Wounds.nsys > 1 and
      not Deny.include?(XMLData.room_id.to_s)
    end

    Extract = %r{exist="(\d+)" noun="(\w+)"}
    def track_perceptive(result)
      return unless result =~ Extract
      id = $1
      noun = $2
      Log.out("perceptive %s detected" % noun)
      Perceptive << id
    end

    def hide!
      case result = dothistimeout("hide", 2, Outcomes::All)
      when Outcomes::Deny
        Deny << XMLData.room_id.to_s
      when Outcomes::Ok
        sleep 0.8
      when Outcomes::Err
        self.track_perceptive(result)
      end
    end

    def camo!
      Spell[608].cast
      #Log.out(result, label: %i(camo))
      @lock = XMLData.room_count unless hidden?
    end

    def apply()
      Timer.await()
      if self.camo?
        self.camo!
      else
        self.hide!
      end
    end
  end
end