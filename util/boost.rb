module Shiva
  module Boost
    def self.loot?
      Effects::Buffs.time_left("Major Loot Boost") > 1 or Effects::Buffs.time_left("Minor Loot Boost") > 1
    end

    def self.loot
      return if Boost.loot?
      %i(loot_major loot_minor).map {|boost| EBoost[boost]}.select(&:available?).sample.use
      EBoost.encumbrance.use if EBoost.encumbrance.available?
    end

    def self.absorb
      return unless Mind.saturated? and EBoost.absorb.available?
      Axp.apply { EBoost.absorb.use }
    end

    def self.experience
      return if Opts["farm"]
      return if Boost.loot?
      return unless EBoost.experience.available?
      return unless Mind.saturated?
      return if Effects::Buffs.active?("Doubled Experience Boost")
      EBoost.experience.use
    end
  end
end