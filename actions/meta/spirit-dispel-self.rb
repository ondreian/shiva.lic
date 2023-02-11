module Shiva
  class ChannelSpiritDispel < Action

    def priority
      Priority.get(:high)
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

    def available?
      Spell[119].known? and
      self.effected?
    end

    def apply()
      waitrt?
      until GameObj.targets.empty? do walk end
      waitcastrt?
      fput "prep 119\rchannel"
      waitcastrt?
      waitrt?
    end
  end
end