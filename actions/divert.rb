module Shiva
  class Divert < Action
    def priority(foe)
      7
    end

    def available?(foe)
      not @env.namespace.eql?(Duskruin) and
      @env.foes.size > 4 and
      CMan.divert > 3 and
      checkstamina > 20 and
      hidden?
    end

    def divert(foe)
      waitrt?
      loot = @env.action("LootArea")
      loot.apply if Claim.mine?
      Stance.offensive
      put "cman divert %s sneak" % foe.noun
      @env.seen << foe.id
      sleep 0.5
      waitrt?
    end

    def apply()
      return self.divert @env.foes.select {|f| f.status.empty?}.sample
    end
  end
end