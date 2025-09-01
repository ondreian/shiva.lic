module Shiva
  class SurgeOfStrength < Action
    def priority
      Priority.get(:medium)
    end

    def cooldown?
      Effects::Cooldowns.active?("Surge of Strength")
    end

    def affordable?
      return checkstamina > 90 if self.cooldown?
      return checkstamina > 35
    end

    def available?
      CMan.surge > 0 &&
      self.affordable? &&
      !Spell["Surge of Strength"].active?
    end

    def apply
      waitcastrt?
      waitrt?
      Spell["Surge of Strength"].cast
      ttl = Time.now + 4
      wait_until {Spell["Surge of Strength"].active? or Time.now > ttl}
    end
  end
end