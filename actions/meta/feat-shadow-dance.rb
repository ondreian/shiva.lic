module Shiva
  class ShadowDance < Action
    def priority
      Priority.get(:high)
    end

    def available?
      checkstamina > 40 and
      not Effects::Buffs.active?("Shadow Dance") and
      not Effects::Cooldowns.active?("Shadow Dance") and
      not %i(bandits escort).include?(self.env.name) and
      %w(Rogue).include?(Char.prof)
    end

    def apply()
      fput "feat shadowdance"
      ttl = Time.now + 3
      wait_until {Effects::Buffs.active?("Shadow Dance") or Time.now > ttl}
    end
  end
end