module Shiva
  class SongOfUnravelling < Action
    def priority
      30
    end

    def needs_dispel?(foe)
      foe.noun.eql?("shaper") or foe.noun.eql?("brawler")
    end

    def available?(foe)
      not foe.nil? and
      not foe.dead? and
      not self.env.seen.include?(foe.id) and
      self.needs_dispel?(foe) and
      Spell[1013].known? and
      Spell[1013].affordable? and
      checkmana > 20 and
      self.env.foes.size < 2 and
      Wounds.nsys < 2 and
      (Group.size.eql?(2) or Group.empty?)
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

    def self.dispel(foe)
      spell = foe.noun.eql?("brawler") ? "1214" : "712"
      dothistimeout("cast #%s %s" % [foe.id, spell], 2, Regexp.union(Ok, Err))
    end

    def apply(foe)
      Stance.guarded
      return if foe.dead?
      fput "prep 1013"
      return if foe.dead?
      result = self.dispel(foe)
      Log.out(result, label: %(unravel))
      case result
      when Ok
        self.env.seen << foe.id
      when Err
        :err
      else
        :unknown
      end
      waitcastrt?
    end
  end
end