module Shiva
  class ChannelElementalDispel < Action

    def priority
      Priority.get(:high)
    end

    def effected?
      Effects::Debuffs.active?("Sounds") or
      Effects::Debuffs.active?("Condemn") or
      Effects::Debuffs.active?("Slow") or 
      Effects::Debuffs.active?("Wild Entropy") or
      Effects::Debuffs.active?("Powersink")
    end

    def available?
      Spell[417].known? and
      self.effected?
    end

    def apply()
      waitrt?
      waitcastrt?
      fput "prep 417\rchannel"
      waitcastrt?
      waitrt?
    end
  end
end