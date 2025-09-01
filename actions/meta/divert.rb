module Shiva
  class Divert < Action
    Diverted ||= []

    def priority(foe)
      self.env.action(:wander).priority - 1
    end

    def room_objs
      GameObj.loot.to_a.map(&:name)
    end

    def fissure?
      GameObj.loot.any? {|i| i.noun.eql?("fissure")}
    end

    def environ?
      #return true if GameObj.targets.any? {|f| f.noun.eql?("monstrosity")}
      return true if self.env.foes.size > self.env.action(:wander).max_foes
      return true if self.fissure?
      return true if self.room_objs.include?("mass of undulating liquified rock")
      return true if self.room_objs.include?("frigid cyclone")
      return false
    end

    def available?
      Lich::Claim.mine? and
      not self.env.name.eql?(:duskruin) and
      not self.divertables.empty? and
      not XMLData.room_exits.empty? and
      self.environ? and
      CMan.divert > 3 and
      checkstamina > 20 and
      not self.env.action_history.count {|i| i.is_a?(Shiva::Divert)} > 2 and
      hidden?
    end

    def divertables
      candidates = self.env.foes.select {|f| f.status.empty?}.reject {|f|Diverted.include?(f.id)}
      if Bounty.task.creature
        bounty_candidates = candidates.select {|f| f.name.eql?(Bounty.creature)}
        return bounty_candidates unless bounty_candidates.empty? 
      end
      return candidates
    end

    def divert(foe)
      waitrt?
      loot = self.env.action(:lootarea)
      loot.apply if Lich::Claim.mine?
      Stance.offensive
      put "cman divert %s sneak" % foe.noun
      Diverted << foe.id
      sleep 0.5
      waitrt?
    end

    def apply()
      return self.divert self.divertables.sample
    end
  end
end