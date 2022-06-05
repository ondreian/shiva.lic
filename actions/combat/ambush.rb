module Shiva
  class Ambush < Action
    DEFAULT_AIMING = %i(head neck back)
    SPEAR_AIMING   = %i(left_eye right_eye head neck)
    CERERBRALITE   = %i(head left_eye right_eye)
    DAGGER_AIMING  = SPEAR_AIMING
    DENY           = []

    attr_accessor :area

    def priority
      91
    end

    def has_melee_skill?
      Skills.polearmweapons > Char.level * 1.5 or
      Skills.edgedweapons > Char.level * 1.5
    end

    def prefer_waylay?(foe)
      %w(destroyer golem).include?(foe.noun) and dagger?
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

    def aiming(foe)
      return DEFAULT_AIMING if %w(crawler siphon).include?(foe.noun)
      return CERERBRALITE   if foe.name.include?("cerebralite") 
      return SPEAR_AIMING if %w(spear harpoon).include?(Char.right.noun)
      return DAGGER_AIMING if self.dagger?
      return DEFAULT_AIMING
    end

    def dagger?
      %w(knife dagger dirk).include?(Char.right.noun)
    end

    # Predator's Eye
    def stance(name)
      return if name.nil?
      return if Effects::Spells.active?(name)
      words = name.downcase.split

      put "cman %s" % (words.include?("stance") ? words.last : words.first.split("'").first)
    end

    def with_stances(before:, after:)
      stance before
      yield
      stance after
    end

    def rogue(foe)
      with_stances(
        before: "Predator's Eye",
         after: "Duck and Weave") { 
          (Effects::Buffs.active?("Shadow Dance") && hidden?) ? self._silent_strike(foe) : self._ambush(foe)
          }
    end

    def warrior(foe)
      return self._ambush(foe)
    end

    def _silent_strike(foe)
      result = dothistimeout("feat silentstrike ##{foe.id}", 1, Outcomes)
      return self.kill(foe) if result =~ /You cannot aim/
    end

    def _ambush(foe)
      result = dothistimeout("ambush ##{foe.id}", 1, Outcomes)
      return self.kill(foe) if result =~ /You cannot aim/
    end

    def get_best_area(foe)
      @area = foe.kill_shot self.aiming(foe)
      Char.aim(@area)
      @area
    end

    def ambush(foe)
      self.get_best_area(foe) unless self.aiming(foe).include?(@area)
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

    def kill(foe)
      Stance.offensive
      dothistimeout("kill ##{foe.id}", 1, Outcomes)
      Timer.await
    end

    def apply(foe)
      waitrt?
      return if foe.dead? or foe.gone?
      return self.ambush foe
    end
  end
end