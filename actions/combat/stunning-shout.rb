module Shiva
  class StunningShout < Action
    def priority
      10 # ? 100 : 10
    end

    def swap?
      self.env.count(:kill) > 5 or
      self.env.count(:hurl) > 5
    end

    def available?(foe)
      not foe.nil? and
      not foe.dead? and
      Spell[1008].known? and
      Spell[1008].affordable? and
      self.swap? and
      (self.env.level.last + 10) > Char.level
    end

    def apply(foe)
      Stance.guarded
      return if foe.dead?
      _result = fput("target #%s\rincant 1008" % foe.id)
      waitcastrt?
    end
  end
end