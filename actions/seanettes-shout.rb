module Shiva
  class SeanettesShout < Action
    def priority
      10
    end

    def active?
      Effects::Buffs.active?("Empowered (+20)")
    end

    def available?
      Char.name.eql?("Etanamir") and # hard-coded for now
      not Effects::Debuffs.active?("Strained Muscles") and
      not cutthroat? and
      Char.stamina > 30 and
      not self.active?
    end

    def apply(_foe)
      fput "warcry sean"
    end
  end
end