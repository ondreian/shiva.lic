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
      
      Walk.apply do
        wait_while { Effects::Cooldowns.active?("Dispel Magic") and GameObj.targets.empty? and self.debuffed? }
        break if not Effects::Cooldowns.active?("Dispel Magic")
        break if not self.debuffed?
        fput "feat dispel" if self.debuffed?
        sleep 0.1
      end
    end
  end
end