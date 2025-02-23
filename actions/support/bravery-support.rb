module Shiva
  class BraverySupport < Action
    def priority
      7
    end

    def ttl
      (@ttl || 0).to_i
    end

    def available?(foe)
      #Log.out(foe)
      foe.nil? and
      self.ttl < Time.now.to_i and
      Spell[211].known? and
      Spell[211].affordable? and
      not self.env.divergence? and
      Group.size > 0 and
      false # Config.support_bravery?
    end

    def apply(foe)
      waitcastrt?
      waitrt?
      Spell[211].cast
      @ttl = Time.now + 60
    end
  end
end