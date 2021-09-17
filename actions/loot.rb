module Shiva
  class Loot < Action
    def priority
      2
    end

    def dead
      GameObj.npcs.to_a.select {|foe| foe.status.include?("dead")}
    end

    def should_unhide?
      return true unless hidden?
      return true if hidden? and @env.foes.size < 3
      return false
    end

    def available?
      Claim.mine? and
      not self.dead.empty? and
      self.should_unhide? and
      Wounds.head < 2 and
      Wounds.nsys < 2 and
      Wounds.leftEye < 2 and
      Wounds.rightEye < 2 and
      (Group.leader? or
      Group.empty?)
    end

    def apply()
      waitrt?
      self.dead.each {|foe|
        if foe.name.include?("monstrosity")
          fput "target #%s" % foe.id
        end

        Creature.new(foe).search()
      }
    end
  end
end