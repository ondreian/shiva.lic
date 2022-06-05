module Shiva
  module Boost
    def self.loot?
      Effects::Buffs.time_left("Major Loot Boost") > 3 or Effects::Buffs.time_left("Minor Loot Boost") > 3
    end
  end
end