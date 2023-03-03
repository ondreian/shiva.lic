module Shiva
  module Boost
    def self.should_boost_loot?
      # no bounty, so probably will rest very quickly
      return false if Bounty.type.eql?(:none)
      # am I loot capped?
      return false if defined?(Ledger) && Ledger::Character.monthly > 14_000_000
      # end of the month, probably approaching loot cap
      return false if !defined?(Ledger) && Time.now.day > 20
      # boost already active
      return false if self.loot?
      # give 'er a go
      return true
    end

    def self.loot?
      Effects::Buffs.time_left("Major Loot Boost") > 1 or Effects::Buffs.time_left("Minor Loot Boost") > 1
    end

    def self.loot
      return if !Boost.should_boost_loot?
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