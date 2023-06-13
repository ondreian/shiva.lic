module Shiva
  class Spellup < Action
    DefensiveSpells = %w(
      101 103 107 120
      211 215
      303 313 319 310 307
      401 406 414 425 430
      503 507 508 509 513 520
      913
      1109
      1606
    ).map(&:to_i)

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
      Stance.guarded
      Walk.apply do
        self.missing.each { |num|
          Walk.away
          return if num.nil?
          Spell[num].cast
        }
      end
    end
  end
end