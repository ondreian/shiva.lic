module Shiva
  class RapidFire < Action
    def priority
      Priority.get(:medium)
    end

    def available?
      Spell[515].known? and
      Spell[515].affordable? and
      not Spell[515].active? and
      Group.empty?
    end

    def apply()
      Spell[515].cast
      ttl = Time.now + 1
      wait_until {Spell[515].active? or Time.now > ttl}
      waitcastrt?
    end
  end
end