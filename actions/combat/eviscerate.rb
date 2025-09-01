module Shiva
  class Eviscerate < Action
    Immune = %w(cerebralite siphon ooze oozeling undansormr angargeist draugr elemental)

    def priority(foe)
      self.env.foes.size > 2 ? 10 : 50
    end

    def available?(foe)
      not foe.nil? and
      not self.env.seen.include?(foe.id) and
      self.env.foes.map(&:status).select {|status| status.empty?}.size > 2  and
      self.env.foes.size > 1 and
      not foe.tall? and
      not Immune.include?(foe.noun) and
      CMan.eviscerate > 2 and
      (Tactic.edged? or Tactic.polearms?) and
      checkstamina > 40 and
      hidden? and
      rand > 0.3
    end

    def eviscerate(foe)
      waitrt?
      Stance.offensive
      dothistimeout "cman eviscerate #%s" % foe.id, 1, %r{You uncoil from the shadows}
      self.env.seen << foe.id
      Timer.await()
    end

    def apply(foe)
      corps = self.env.foes.select {|foe| 
        !foe.type.include?("noncorporeal") && !%w(grotesque).include?(foe.noun)
      }
      target = corps.find {|foe| foe.status.empty?} || corps.sample || foe
      self.env.seen << foe.id
      return self.eviscerate(target)
    end
  end
end