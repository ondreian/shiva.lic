# Dispel Magic
module Shiva
  class FeatDispel < Action
    def priority
      Priority.get(:high)
    end

    def debuffed?
      not Effects::Debuffs.to_h.keys.select {|k| k.is_a?(String)}.reject {|k| k =~ /Wall of Thorns|Vulnerable|Confused|Crippled/i}.empty?
    end

    def available?
      checkstamina > 40 and
      not Effects::Buffs.active?("Dispel Magic") and
      Feat.dispel_magic > 0 and
      self.debuffed?
    end

    def apply()
      waitrt?
      loop {
        until GameObj.targets.empty? do walk end
        wait_while { Effects::Cooldowns.active?("Dispel Magic") and GameObj.targets.empty? and self.debuffed? }
        break if not Effects::Cooldowns.active?("Dispel Magic")
        break if not self.debuffed?
        sleep 0.1
      }

      fput "feat dispel" if self.debuffed?
    end
  end
end