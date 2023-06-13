module Shiva
  class Hurl < Action
    attr_accessor :area

    Unaimed ||= []

    Deflectors = %w(protector)

    def priority
      91
    end

    def has_thrown_skill?
      Tactic.thrown?
    end

    def available?(foe)
      not foe.nil? and
      not Deflectors.include?(foe.noun) and
      Tactic.thrown?
    end

    Outcomes = Regexp.union(
      /^With a quick flick of your wrist/,
      /^You take aim/,
      /You cannot aim/,
      %r[is already dead],
      %r[What were you referring to],
      %r[does not have a (.*)!]
    )

    def get_best_area(foe)
      @area = foe.kill_shot Aiming.lookup(foe)
      Log.out("{foe=%s, aim=%s}" % [foe.name, @area])
      Char.aim(@area)
      @area
    end

    def _hurl(foe, aiming: :clear)
      case dothistimeout("hurl #%s %s" % [foe.id, aiming], 2, Outcomes)
      when %r[You cannot aim]
        Unaimed << foe.id
      end
      Timer.await
    end

    def aimed_hurl(foe)
      self.get_best_area(foe) unless Aiming.lookup(foe).include?(@area)
      self._hurl(foe, aiming: @area)
    end

    def unaimed_hurl(foe)
      self._hurl(foe)
    end

    def apply(foe)
      waitrt?
      return if foe.dead? or foe.gone?
      Stance.offensive
      Log.out("hurling %s" % @area, label: %i(hurl area))
      return self.unaimed_hurl(foe) if Unaimed.include?(foe.id)
      return self.aimed_hurl(foe)   if Skills.perception > Char.level * 2
      return self.unaimed_hurl(foe)
    end
  end
end