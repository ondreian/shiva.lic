module Shiva
  class Tremors < Action
    def priority
      10
    end

    def available?(foe)
      Spell[909].known? and
      Spell[909].affordable? and
      not Spell[909].active? and 
      foe.nil?
    end

    def apply(foe)
      Stance.guarded
      fput "incant 909"
      ttl = Time.now + 2
      wait_until {Time.now > ttl or Spell[909].active? }
    end
  end
end