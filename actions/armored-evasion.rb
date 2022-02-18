module Shiva
  class ArmoredEvasion < Action
    def priority
      10
    end

    def active?
      Effects::Spells.active?("Armored Evasion")
    end

    def available?
      Char.name.eql?("Ondreian") and # todo: hard-coded for now
      not Effects::Debuffs.active?("Strained Muscles") and
      not self.active?
    end

    def apply(_foe)
      fput "armor evasion"
    end
  end
end