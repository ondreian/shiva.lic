module Shiva
  class Ambush < Action
    attr_accessor :area

    DENY ||=[]

    def priority
      91
    end

    def has_melee_skill?
      Tactic.edged? or Tactic.polearms? or Tactic.brawling?
    end

    def prefer_waylay?(foe)
      %w(golem automaton).include?(foe.noun) and Tactic.dagger?
    end

    def in_reach?(foe)
      return true if foe.tall? and (foe.status.include?(:frozen) or foe.status.include?(:prone))
      return true if !foe.tall?
      return false
    end

    def able?(foe)
      return :open unless hidden?
      return :deny if DENY.include?(foe.id)
      return :no_melee unless self.has_melee_skill? 
      return :no_ambush unless Skills.ambush > Char.level
      return :no_foe if foe.nil?
      return true
      #self.in_reach?(foe)
    end

    def available?(foe)
      #Log.out(self.able?(foe), label: %i(ambush able))
      self.able?(foe).eql?(true)
    end

    Outcomes = Regexp.union(
      /^You (swing|thrust|throw)/,
      /^You take aim/,
      /You cannot aim/,
      %r[is already dead],
      %r[What were you referring to],
      %r[does not have a (.*)!]
    )

    def rogue(foe)
      Martial::Stance.swap {
        if Effects::Buffs.active?("Shadow Dance") && hidden? && checkstamina > 0
          self._silent_strike(foe)
        else
          self._ambush(foe)
        end
      }
    end

    def warrior(foe)
      return self._ambush(foe)
    end

    def verb(foe)
      return "punch" if Tactic.uac? && %w(crawler).include?(foe.noun)
      return "kick" if Tactic.uac? && Spell[506].active?
      return "punch" if Tactic.uac?
      return "ambush"
    end

    def _silent_strike(foe)
      cmd = self.in_reach?(foe) ? "feat silentstrike %s #%s" : "feat silentstrike #%s clear"
      result = dothistimeout(cmd % [self.verb(foe), foe.id], 1, Outcomes)
      return self.kill(foe, silent: true) if result =~ /You cannot aim|does not have/
    end

    def _ambush(foe)
      cmd = self.in_reach?(foe) ? "%s #%s" : "%s #%s clear"
      result = dothistimeout(cmd % [self.verb(foe), foe.id], 1, Outcomes)
      return self.kill(foe, silent: false) if result =~ /You cannot aim|does not have/
    end

    def get_best_area(foe)
      @area = foe.kill_shot Aiming.lookup(foe)
      Log.out("{foe=%s, aim=%s}" % [foe.name, @area])
      @area=:clear if @area.eql?(:neck) and foe.noun.eql?("cerebralite")
      Char.aim(@area)
      @area
    end

    def ambush(foe)
      if self.in_reach?(foe)
        self.get_best_area(foe) unless Aiming.lookup(foe).include?(@area)
      end
      waitrt?
      Stance.offensive
      Log.out("ambushing %s" % @area, label: %i(ambush area))
      case Char.prof
      when "Rogue"
        self.rogue(foe)
      when "Warrior"
        self.warrior(foe)
      else
        self._ambush(foe)
      end
      # look and parse the next best killshot while in roundtime
      unless foe.dead? or foe.gone?
        self.get_best_area(foe)
        Log.out("%s -> %s" % [foe.name, @area], label: %i(killshot))

        if %w(destroyer crawler).include?(foe.noun) and not %i(head neck).include?(@area) and not Tactic.uac?
          return DENY << foe.id
        end
      end
      Timer.await
    end

    def kill(foe, silent:)
      Stance.offensive
      cmd = "%s #%s clear" % [hidden? ? "waylay" : "attack", foe.id]
      cmd = "feat silent %s" % cmd if silent
      dothistimeout(cmd, 1, Outcomes)
      Timer.await
    end

    def apply(foe)
      waitrt?
      return if foe.dead? or foe.gone?
      return self.ambush foe
    end
  end
end