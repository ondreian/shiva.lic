module Shiva
  module Boost
    def self.loot?
      Effects::Buffs.time_left("Major Loot Boost") > 1 or Effects::Buffs.time_left("Minor Loot Boost") > 3
    end
  end
end