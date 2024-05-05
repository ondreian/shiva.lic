# Dispel Magic
module Shiva
  class FeatDispel < Action
    def priority
      -100
    end

    def cooldown
      @cooldown ||= Time.now
    end

    def debuffs
      Effects::Debuffs.to_h.keys.select {|k| k.is_a?(String)}.reject {|k| k =~ /Wall of Thorns|Vulnerable|Confused|Crippled/i}
    end

    def debuffed?
      not self.debuffs.empty?
    end

    def available?
      checkstamina > 40 and
      not Effects::Cooldowns.active?("Dispel Magic") and
      Feat.dispel_magic > 0 and
      Time.now > self.cooldown and
      self.debuffed?
    end

    def apply()
      waitrt?
      if self.debuffed?
        @cooldown = Time.now + 20
        Log.out(self.debuffs)
        fput "feat dispel"
      end
    end
  end
end