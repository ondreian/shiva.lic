module Shiva
  class SmallStatue < Action
    def priority
      1_000 #Priority.get(:high)
    end

    def statue
      Containers.lootsack.where(name: "small statue").first
    end

    def available?(foe)
      return false if self.statue.nil?
      return false if Feat.kroderine_soul > 0
      return false if Effects::Spells.active?("Spirit Guard")
      return self.env.foes.size == 0
    end

    def apply()
      begin
        stat = self.statue
        Hand.use {
          stat.take
          fput "rub #%s" % stat.id
          Containers.lootsack.add(stat) if [Char.left.id, Char.right.id].include?(stat.id)
        }
        ttl = Time.now + 2
        wait_until {Effects::Spells.active?("Spirit Guard") or Time.now > ttl}
      rescue
        empty_hands
        Char.arm
      end
    end
  end
end