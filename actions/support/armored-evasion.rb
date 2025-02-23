module Shiva
  class ArmoredEvasion < Action
    @tags = %i(setup)
    
    def priority
      5
    end

    def active?
      Effects::Spells.active?("Armored Evasion")
    end

    def available?
      Armor.known?("Armored Evasion") and # todo: hard-coded for now
      not Effects::Debuffs.active?("Strained Muscles") and
      not self.active?
    end

    def apply(_foe)
      fput "armor evasion"
    end
  end
end