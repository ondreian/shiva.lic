module Shiva
  class BurstOfSwiftness < Action
    def priority
      Priority.get(:medium)
    end

    def cooldown?
      Spell["Burst of Swiftness Cooldown"].active?
    end

    def affordable?
      return checkstamina > 65 if self.cooldown?
      return checkstamina > 35
    end

    def available?
      return false
      CMan.burst_of_swiftness > 2 &&
      self.affordable?
    end

    def apply
      waitcastrt?
      waitrt?
      Spell["Burst of Swiftness"].cast
      ttl = Time.now + 4
      wait_until {Spell["Burst of Swiftness"].active? or Time.now > ttl}
    end
  end
end