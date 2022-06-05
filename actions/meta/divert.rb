module Shiva
  class Divert < Action
    def priority(foe)
      self.environ? ? 1 : Priority.get(:medium)
    end

    def room_objs
      GameObj.loot.to_a.map(&:name)
    end

    def fissure?
      GameObj.loot.any? {|i| i.noun.eql?("fissure")}
    end

    def environ?
      return true if self.env.foes.size > 4
      return true if self.fissure?
      return true if self.room_objs.include?("mass of undulating liquified rock")
      return true if self.room_objs.include?("frigid cyclone")
      return false
    end

    def available?()
      not self.env.name.eql?(:duskruin) and
      not self.divertables.empty? and
      self.environ? and
      CMan.divert > 3 and
      checkstamina > 20 and
      hidden?
    end

    def divertables
      self.env.foes.select {|f| f.status.empty?}
    end

    def divert(foe)
      waitrt?
      loot = self.controller.action(:lootarea)
      loot.apply if Claim.mine?
      Stance.offensive
      put "cman divert %s sneak" % foe.noun
      self.env.seen << foe.id
      sleep 0.5
      waitrt?
    end

    def apply()
      return self.divert self.divertables.sample
    end
  end
end