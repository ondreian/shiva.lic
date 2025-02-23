# Martial Prowess
module Shiva
  class MoonstoneCube < Action
    @tags = %i(setup)
    
    def priority
      Priority.get(:high)
    end

    def cube
      Containers.lootsack.where(name: /moonstone cube/).first
    end

    def available?(foe)
      return false if self.cube.nil?
      return false if Feat.kroderine_soul > 0
      return false if Effects::Spells.active?("Martial Prowess")
      return self.env.foes.size == 0
    end

    def apply()
      begin
        item = self.cube
        waitcastrt?
        waitrt?
        Hand.use {
          item.take
          dothistimeout "rub #%s" % item.id, 3, /you rub/i
          Containers.lootsack.add(item) if [Char.left.id, Char.right.id].include?(item.id)
        }
        ttl = Time.now + 2
        wait_until {Effects::Spells.active?("Martial Prowess") or Time.now > ttl}
      rescue Exception => e
        Log.out(e)
        empty_hands
        Arms.use
      end
    end
  end
end