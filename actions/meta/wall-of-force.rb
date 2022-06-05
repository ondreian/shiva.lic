module Shiva
  class WallOfForce < Action
    def priority
      Priority.get(:medium)
    end

    def available?(foe)
      Spell[140].known? and
      checkmana > 400 and
      not Spell[140].active? and
      %w(Empath Cleric).include?(Char.prof) and
      Group.members.empty? and
      foe.nil? and
      GameObj.targets.to_a.empty?
    end

    def apply()
      fput "incant 140"
    end
  end
end