module Shiva
  class ChannelSpiritDispel < Action
    def priority
      1
    end

    def effected?
      Effects::Debuffs.active?("Sounds") or
      Effects::Debuffs.active?("Condemn") or
      Effects::Debuffs.active?("Slow")
    end

    def available?
      Spell[119].known? and
      self.effected?
    end

    def apply()
      waitrt?
      waitcastrt?
      fput "prep 119\rchannel"
      waitcastrt?
      waitrt?
    end
  end
end