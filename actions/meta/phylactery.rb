#phylactery

module Shiva
  class Phylactery < Action
    def priority
      -2
    end

    def phylactery
      GameObj.loot.find {|i| i.noun.eql?(%[phylactery])}
    end

    def lich
      Foes.find &Where[noun: "lich"]
    end

    def available?
      Lich::Claim.mine? and
      not self.phylactery.nil?# and
      #self.lich.nil?
    end

    def apply
      Char.arm if checkright.nil?
      haste = @env.action(:haste)
      haste.apply if haste.available?
      Char.unhide if hidden?
      Stance.defensive
      Char.stand unless standing?
      fput "attack #%s" % phylactery.id
    end
  end
end