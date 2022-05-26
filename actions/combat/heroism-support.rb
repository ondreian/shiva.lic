module Shiva
  class HeroismSupport < Action
    def priority
      7
    end

    def ttl
      (@ttl || 0).to_i
    end

    def available?(foe)
      foe.nil? and
      self.ttl < Time.now.to_i and
      Spell[215].known? and
      Spell[215].affordable? and
      Group.size > 0 and
      not checkpcs.include?("Pixelia")
    end

    def apply(foe)
      waitcastrt?
      waitrt?
      Spell[215].cast
      @ttl = Time.now + 120
    end
  end
end