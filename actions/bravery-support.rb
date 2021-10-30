module Shiva
  class BraverySupport < Action
    def priority
      8
    end

    def ttl
      (@ttl || 0).to_i
    end

    def available?(foe)
      #Log.out(foe)
      foe.nil? and
      self.ttl < Time.now.to_i and
      Spell[211].known? and
      Spell[211].affordable?  and
      Group.size > 0
    end

    def apply(foe)
      waitcastrt?
      fput "incant 211"
      @ttl = Time.now + 120
    end
  end
end