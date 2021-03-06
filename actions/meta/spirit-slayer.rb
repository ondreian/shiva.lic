module Shiva
  class SpiritSlayer < Action
    def priority
      Priority.get(:medium)
    end

    def available?(foe)
      foe.nil? and
      Spell[240].known? and
      percentmana > 30 and
      not Spell[240].active? and
      Group.size < 3 and
      GameObj.targets.to_a.empty?
    end

    def apply(foe)
      waitcastrt?
      Spell[240].cast()
      ttl = Time.now + 2
      wait_until {Spell[240].active? or Time.now > ttl}
    end
  end
end