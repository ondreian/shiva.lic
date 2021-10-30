module Shiva
  class WallOfForce < Action
    def priority
      5
    end

    def available?
      Spell[140].known? and
      checkmana > 100 and
      not Spell[140].active? and
      %w(Empath Cleric).include?(Char.prof)
    end

    def apply()
      fput "incant 140"
    end
  end
end