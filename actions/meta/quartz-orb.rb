# Mystic Focus
module Shiva
  class QuartzOrb < Action
    def priority
      Priority.get(:high)
    end

    def orb
      Containers.lootsack.where(name: /quartz orb/).first
    end

    def available?(foe)
      return false if %w(Rogue Warrior).include?(Char.prof)
      return false if self.orb.nil?
      return false if Effects::Spells.active?("Mystic Focus")
      return false if Feat.kroderine_soul > 0
      return self.env.foes.size == 0
    end

    def apply()
      item = self.orb
      waitcastrt?
      Hand.use {
        item.take
        fput "rub #%s" % item.id
        sleep 0.2
        Containers.lootsack.add(item) if [Char.left.id, Char.right.id].include?(item.id)
      }
      ttl = Time.now + 2
      wait_until {Effects::Spells.active?("Mystic Focus") or Time.now > ttl}
    end
  end
end