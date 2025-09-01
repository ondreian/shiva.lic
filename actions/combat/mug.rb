module Shiva
  class Mug < Action
    Mugged = []

    def priority(foe)
      62
    end

    def situationals(foe)
      return true if %w(crusader).include?(foe.noun)
      return true if Boost.loot? and checkstamina > 70
      return !Effects::Buffs.active?("Shadow Dance")
    end

    def below_lootcap?
      defined?(Ledger) and Ledger::Character.estimate_loot_cap < 20_000_000
    end

    def available?(foe)
      not self.env.name.eql?(:duskruin) and
      not foe.nil? and
      self.below_lootcap? and
      not checkloot.to_a.include?("thorny vine") and
      self.situationals(foe) and
      not Mugged.include?(foe.id) and
      not %w(warg mastodon hinterboar).include?(foe.noun) and
      not foe.status.empty? and
      CMan.mug > 0 and
      Tactic.edged? and
      checkstamina > 40 and
      hidden? and
      rand > 0.1
    end

    def mug(foe)
      Timer.await
      Stance.offensive
      Martial::Stance.swap {
        dothistimeout "cman mug #%s" % foe.id, 2, %r{You boldly accost}
      }
      Mugged << foe.id
      sleep 0.5
      Timer.await
    end

    def apply(foe)
      return self.mug foe
    end
  end
end