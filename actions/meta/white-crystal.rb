# Mystic Focus
module Shiva
  class WhiteCrystal < Action
    def priority
      Priority.get(:high)
    end

    def crystal
      Containers.lootsack.where(name: /white crystal/).first
    end

    def active?
      Effects::Spells.active?("Strength")
    end

    def available?(foe)
      return false if self.crystal.nil?
      return false if self.active?
      return false if Feat.kroderine_soul > 0
      return self.env.foes.size == 0
    end

    def apply()
      item = self.crystal
      waitcastrt?
      Hand.use {
        item.take
        fput "rub #%s" % item.id
        sleep 0.2
        Containers.lootsack.add(item) if [Char.left.id, Char.right.id].include?(item.id)
      }
      ttl = Time.now + 2
      wait_until {self.active? or Time.now > ttl}
    end
  end
end