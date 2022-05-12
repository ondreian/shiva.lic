module Shiva
  class Mug < Action
    Mugged = []

    def priority(foe)
      62
    end

    def available?(foe)
      not self.env.name.eql?(:duskruin) and
      not foe.nil? and
      not checkloot.to_a.include?("thorny vine") and
      not Effects::Buffs.active?("Shadow Dance") and
      not Mugged.include?(foe.id) and
      not foe.status.empty? and
      CMan.mug > 0 and
      checkstamina > 40 and
      hidden? and
      rand > 0.1
    end

    def mug(foe)
      waitrt?
      Stance.offensive
      put "cman mug #%s" % foe.id
      Mugged << foe.id
      sleep 0.5
      waitrt?
    end

    def apply(foe)
      waitrt?
      return self.mug foe
    end
  end
end