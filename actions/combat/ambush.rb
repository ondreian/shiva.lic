module Shiva
  class Ambush < Action
    attr_accessor :area

    DENY ||=[]

    def priority
      91
    end

    def has_melee_skill?
      Tactic.edged? or Tactic.polearms?
    end

    def prefer_waylay?(foe)
      %w(destroyer golem automaton).include?(foe.noun) and Tactic.dagger?
    end

    def in_reach?(foe)
      return true if foe.tall? and (foe.status.include?(:frozen) or foe.status.include?(:prone))
      return true if !foe.tall?
      return false
    end

    def able?(foe)
      hidden? and
      not DENY.include?(foe.id) and
      self.has_melee_skill? and
      Skills.ambush > Char.level and
      not foe.nil? and
      self.in_reach?(foe)
    end

    def available?(foe)
      self.prefer_waylay?(foe) or self.able?(foe)
    end

    Outcomes = Regexp.union(
      /^You (swing|thrust|throw)/,
      /^You take aim/,
      /You cannot aim/,
      %r[is already dead],
      %r[What were you referring to],
    )

    # Predator's Eye
    def stance(name, cmd)
      return if name.eql?(:noop)
      return if Effects::Spells.active?(name)
      put "cman %s" % cmd
    end

    def with_stances()
      stance(*self.offensive_martial_stance)
      yield
      stance(*self.defensive_martial_stance)
    end

    def offensive_martial_stance()
      return ["Whirling Dervish", "dervish"] if CMan.whirling_dervish && self.env.foes.size > 1 && GameObj.left_hand.type.include?("weapon")
      return ["Predator's Eye", "predator"]   if CMan.predators_eye
      return [:noop, nil]
    end

    def defensive_martial_stance()
      return ["Duck and Weave", "duck"] if CMan.duck_and_weave
      return [:noop, nil]
    end

    def rogue(foe)
      with_stances {
        (Effects::Buffs.active?("Shadow Dance") && hidden?) ? self._silent_strike(foe) : self._ambush(foe)
      }
    end

    def warrior(foe)
      return self._ambush(foe)
    end

    def _silent_strike(foe)
      result = dothistimeout("feat silentstrike ##{foe.id}", 1, Outcomes)
      return self.kill(foe, silent: true) if result =~ /You cannot aim/
    end

    def _ambush(foe)
      result = dothistimeout("ambush ##{foe.id}", 1, Outcomes)
      return self.kill(foe, silent: false) if result =~ /You cannot aim/
    end

    def get_best_area(foe)
      @area = foe.kill_shot Aiming.lookup(foe)
      Log.out("{foe=%s, aim=%s}" % [foe.name, @area])
      Char.aim(@area)
      @area
    end

    def ambush(foe)
      self.get_best_area(foe) unless Aiming.lookup(foe).include?(@area)
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
      unless foe.dead?
        self.get_best_area(foe)
        Log.out("%s -> %s" % [foe.name, @area], label: %i(killshot))

        if foe.noun.eql?("destroyer") and not %w(head neck).include?(@area)
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