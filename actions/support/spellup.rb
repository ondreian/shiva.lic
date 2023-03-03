module Shiva
  class Spellup < Action
    DefensiveSpells = %w(
      101 103 107 120
      401 406 414 425 430
      1109
      503 507 508 509 513 520
      913
      303 313 319 310 307
    )

    def priority
      1
    end

    def missing
      DefensiveSpells.select {|num|
        next unless num
        Spell[num].known? and 
        not Spell[num].active? and
        Spell[num].affordable?
      }
    end

    def available?(foe)
      self.missing.size > 0 && !%i(escort).include?(Bounty.type)
    end

    def apply(foe)
      until GameObj.targets.empty? do walk end
      Stance.guarded
      num = self.missing.first
      return if num.nil?
      Spell[num].cast
    end
  end
end