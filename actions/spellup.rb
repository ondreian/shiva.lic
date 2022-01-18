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
      3
    end

    def missing
      DefensiveSpells.select {|num| 
        Spell[num].known? and 
        not Spell[num].active? and
        Spell[num].affordable?
      }
    end

    def available?(foe)
      foe.nil? and
      self.missing.size > 0
    end

    def apply(foe)
      Stance.guarded
      self.missing.each {|num| Spell[num].cast}
    end
  end
end