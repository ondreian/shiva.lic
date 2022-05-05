module Shiva
  class Loot < Action
    Skinnable = %w(cerebralite lich sidewinder crawler)

    def priority
      2
    end

    def dead
      GameObj.npcs.to_a.select {|foe| foe.status.include?("dead")}
    end

    def should_unhide?
      return true unless hidden?
      return true if hidden? and @env.foes.size < 5
      return false
    end

    def available?
      Claim.mine? and
      not @env.namespace.eql?(Duskruin) and
      not self.dead.empty? and
      self.should_unhide? and
      Wounds.head < 2 and
      Wounds.nsys < 2 and
      Wounds.leftEye < 2 and
      Wounds.rightEye < 2 and
      (Group.leader? or
      Group.empty?)
    end

    def maybe_skin(creature)
      return unless Skinnable.include?(creature.noun)
      return unless %w(dirk dagger knife).include?(Char.right.noun)
      return unless (Skills.survival + Skills.firstaid) / (Char.level * 0.5) > 0.5
      fput "skin #%s" % creature.id
    end

    def apply()
      waitrt?
      self.dead.each {|foe|
        creature = Creature.new(foe)
        self.maybe_skin(creature)
        creature.search()
      }
    end
  end
end