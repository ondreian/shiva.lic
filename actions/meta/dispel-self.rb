module Shiva
  class DispelSelf < Action

    def priority
      -100
    end

    def effected?
      Effects::Debuffs.active?("Sounds") or
      Effects::Debuffs.active?("Condemn") or
      Effects::Debuffs.active?("Slow") or 
      Effects::Debuffs.active?("Wild Entropy") or
      Effects::Debuffs.active?("Powersink") or
      Effects::Debuffs.active?("Mindwipe") or
      Effects::Debuffs.active?("Pious Trial") or
      Effects::Debuffs.active?("Thought Lash") or
      Effects::Debuffs.active?("Confusion") or
      Effects::Debuffs.active?("Vertigo")
    end

    def cast?
      Spell[119].known? or Spell[417].known?
    end

    def available?
      self.cast? and
      self.effected?
    end

    def apply()
      Walk.apply do
        if Spell[417].known?
          fput "prep 417\rchannel"
        elsif Spell[119].known?
          fput "prep 119\rchannel"
        end
        waitcastrt?
        waitrt?
      end
    end
  end
end