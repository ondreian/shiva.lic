module Shiva
  class Smite < Action
    Uncrittable = %w(crusader conjurer)
    Smited = []

    def self.smited?(foe)
      Smited.include?(foe.id)
    end

    def priority
      6
    end

    def available?(foe)
      Skills.brawling > Char.level * 1.5 and
      not Effects::Debuffs.active?("Jaws") and
      not Smited.include?(foe.id) and
      not Uncrittable.include?(foe.noun) and
      hidden? and
      foe.tags.include?(:noncorporeal)
    end

    def smite(foe)
      Stance.offensive
      result = dothistimeout "smite #%s" % foe.id, 1, Regexp.union(
        %r[is unwillingly drawn into the corporeal plane],
        %r[wait]
      )
      Smited << foe.id if result =~ %r{is unwillingly drawn into the corporeal plane}
      sleep 0.5
      Timer.await() if checkrt > 6
    end

    def apply(foe)
      return self.smite foe
    end
  end
end