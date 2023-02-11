# Absorb Magic

module Shiva
  class FeatAbsorb < Action
    def priority
      Priority.get(:high)
    end

    def available?
      not Effects::Buffs.active?("Absorb Magic") and
      not Effects::Cooldowns.active?("Absorb Magic") and
      Feat.absorb_magic > 0 and
      not stunned? and
      muckled?
    end

    def apply()
      fput "feat absorb"
    end
  end
end