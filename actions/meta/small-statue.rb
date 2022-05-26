module Shiva
  class SmallStatue < Action
    def priority
      5
    end

    def statue
      Containers.lootsack.where(name: "small statue").first
    end

    def available?(foe)
      return false if self.statue.nil?
      return false if Effects::Spells.active?("Spirit Guard")
      return self.env.foes.size == 0
    end

    def apply()
      stat = self.statue
      Log.out(stat.inspect)
      empty_left_hand
      stat.take
      fput "rub #%s" % stat.id
      Containers.lootsack.add(stat) if [Char.left.id, Char.right.id].include?(stat.id)
      fill_left_hand
      ttl = Time.now + 2
      wait_until {Effects::Spells.active?("Spirit Guard") or Time.now > ttl}
    end
  end
end