module Shiva
  class SongOfUnravelling < Action
    def priority
      30
    end

    def needs_dispel?(foe)
      foe.noun.eql?("shaper") or foe.noun.eql?("fanatic")
    end

    def available?(foe)
      not foe.nil? and
      not foe.dead? and
      not @env.seen.include?(foe.id) and
      self.needs_dispel?(foe) and
      Spell[1013].known? and
      Spell[1013].affordable? and
      checkmana > 20 and
      @env.foes.size < 2 and
      Wounds.nsys < 2
    end

    Ok  = Regexp.union(
      %r{swirls and sparkles, but quickly returns to normal.},
      %r{swirls and sparkles brightly!},
      %r{A little bit late for that don't you think}
    )

    Err = Regexp.union(
      %r{dissipating it harmlessly.},
      %r{Your armor prevents the song from working correctly.},
      %r{d100 == 1 FUMBLE!}
    )

    def apply(foe)
      Stance.guarded
      return if foe.dead?
      fput "prep 1013"
      return if foe.dead?
      result = dothistimeout("cast #%s 712" % foe.id, 2, Regexp.union(Ok, Err))
      Log.out(result, label: %(unravel))
      case result
      when Ok
        @env.seen << foe.id
      when Err
        :err
      else
        :unknown
      end
      waitcastrt?
    end
  end
end