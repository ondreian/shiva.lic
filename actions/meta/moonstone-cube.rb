# Martial Prowess
module Shiva
  class MoonstoneCube < Action
    def priority
      Priority.get(:high)
    end

    def cube
      Containers.lootsack.where(name: /moonstone cube/).first
    end

    def available?(foe)
      return false if self.cube.nil?
      return false if Effects::Spells.active?("Martial Prowess")
      return self.env.foes.size == 0
    end

    def apply()
      item = self.cube
      Log.out(item.inspect)
      empty_left_hand
      item.take
      fput "rub #%s" % item.id
      Containers.lootsack.add(item) if [Char.left.id, Char.right.id].include?(item.id)
      fill_left_hand
      ttl = Time.now + 2
      wait_until {Effects::Spells.active?("Martial Prowess") or Time.now > ttl}
    end
  end
end