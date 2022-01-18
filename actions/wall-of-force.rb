module Shiva
  class WallOfForce < Action
    def priority
      5
    end

    def available?
      Spell[140].known? and
      checkmana > 200 and
      not Spell[140].active? and
      %w(Empath Cleric).include?(Char.prof) and
      Group.members.empty?
    end

    def apply()
      fput "incant 140"
    end
  end
end