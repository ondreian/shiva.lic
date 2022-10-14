# Dispel Magic
module Shiva
  class FeatDispel < Action
    def priority
      Priority.get(:high)
    end

    def available?
      checkstamina > 40 and
      not Effects::Buffs.active?("Dispel Magic") and
      not Effects::Cooldowns.active?("Dispel Magic") and
      Feat.dispel_magic > 0 and
      not Effects::Debuffs.to_h.reject {|k,v| k =~ /Wall of Thorns/i}.empty?
    end

    def apply()
      fput "feat dispel"
    end
  end
end