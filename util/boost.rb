module Shiva
  module Boost
    def self.loot?
      Effects::Buffs.time_left("Major Loot Boost") > 1 or Effects::Buffs.time_left("Minor Loot Boost") > 1
    end

    def self.boost_loot
      [::Boost[:loot_major], ::Boost[:loot_minor]].select {|boost| boost.remaining > 0}.sample.use
    end
  end
end