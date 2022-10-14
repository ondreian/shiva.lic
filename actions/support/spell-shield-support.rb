module Shiva
  class SpellShieldSupport < Action
    def priority
      10_000
    end

    def ttl
      (@ttl || 0).to_i
    end

    def available?(foe)
      foe.nil? and
      self.ttl < Time.now.to_i and
      Spell[219].known? and
      Spell[219].affordable? and
      not self.env.divergence? and
      Group.size > 0 and
      not checkpcs.include?("Pixelia")
    end

    def apply(foe)
      waitcastrt?
      waitrt?
      Spell[219].cast
      @ttl = Time.now + 60
    end
  end
end