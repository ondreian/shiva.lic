module Shiva
  class Lullabye < Action
    Slept = []
    Nouns = %w(lurk shaper protector)

    def priority
      29
    end

    def available?(foe)
      not foe.nil? and
      not foe.dead? and
      Nouns.include?(foe.noun) and
      Group.empty? and
      foe.status.empty? and
      not Slept.include?(foe.id) and
      Spell[1005].known? and
      Spell[1005].affordable? and
      checkmana > 20 and
      self.env.foes.size < 2 and
      Wounds.nsys < 2
    end

    def apply(foe)
      Stance.guarded
      return if foe.dead?
      _result = fput("target #%s\rincant 1005" % foe.id)
      Slept << foe.id
      waitcastrt?
    end
  end
end