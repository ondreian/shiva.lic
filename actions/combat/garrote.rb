module Shiva
  class Garrote < Action
    Nouns = %w(master crawler destroyer)

    def priority
      60
    end

    def cost
      20
    end

    def available?(foe)
      Nouns.include?(foe.noun) and
      CMan.garrote > 0 and
      not foe.status.empty? and
      self.env.foes.size.eql?(1) and
      not Effects::Cooldowns.active?("Garrote") and
      not Effects::Buffs.active?("Enh. Agility (+10)") and
      not Effects::Debuffs.active?("Rift Slow") and
      not self.garrote.nil? and
      not self.env.name.eql?(:duskruin) and
      checkstamina > self.cost and
      Group.empty? and
      hidden? and
      not foe.tall? and
      not Spell[1035].active? and
      rand > 0.2
    end

    def garrote
      Containers.harness.where(name: %[veniom-wrapped long copper wire]).first
    end

    module Outcomes
      TooTall = %r[neck is out of reach!]
      LowRoll = %r[You attempt to snap it taut]
      Err = Regexp.union(TooTall, LowRoll)
      Ok  = %r[neck and snap it taut.  Success!]
      All = Regexp.union(Err, Ok)
    end

    def wait_for_death(foe)
      ttl = Time.now + 15
      loop {
        sleep 0.1
        line = get?
        break if foe.dead? or foe.gone?
        break if Time.now > ttl
        next if line.nil?
        break if line =~ %r[You release the garrote and let your victim's corpse fall to the ground.]
        break if line =~ %r[Your concentration lapses and you are unable to complete the maneuver.]
      }
    end

    def apply(foe)
      sleep 0.3
      waitrt?
      return if foe.dead? or foe.gone?
      Stance.defensive
      Char.unarm
      ttl = Time.now + 3
      wait_until {Char.right.nil? && Char.left.nil? or Time.now > ttl}
      return Char.arm if foe.dead? or foe.gone?
      self.garrote.use {
        3.times {fput "hide"; break if hidden?}
        next unless hidden?
        Stance.offensive
        res = dothistimeout("cman garrote #%s" % foe.id, 1, Outcomes::All)
        self.wait_for_death(foe) if res =~ Outcomes::Ok
        waitrt?
      }
      sleep 0.3
      10.times {
        break if Char.right.nil? && Char.left.nil?
        Containers.harness.add(*[Char.right, Char.left].compact)
      }

      Char.arm
    end
  end
end