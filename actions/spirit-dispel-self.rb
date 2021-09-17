module Shiva
  class ChannelSpiritDispel < Action
    def priority
      1
    end

    def available?
      Spell[119].known? and
      Effects::Debuffs.active?("Condemn")
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