module Shiva
  module Duskruin
    class Teardown < Stage
      def reset
        :noop
      end

      def bard
        return unless Char.prof.eql?("Bard")
        fput "renew all" if Duskruin::Rooms.combat.include?(Room.current.id)
      end

      def spellup
        spells = %w(120 425 430).map {|num| Spell[num]}.select(&:known?)
        while Duskruin::Rooms.combat.include?(Room.current.id)
          spell = spells.shuffle.shift
          spell.cast if spell.known? and spell.affordable?
          break if percentmana < 20 or spells.empty?
        end
      end

      def apply(env)
        waitrt?
        Char.unarm
        fput "loot area"
        Script.kill("signore")
        self.bard
        self.spellup
        wait_until {Char.right.noun.eql?("package")}
        fput "open my package"
        fput "look in my package"
        wait_while {GameObj.right_hand.contents.nil?}
        Containers.lootsack.add(*Containers.right_hand)
        fput "drop my package"
        if Group.empty?
          Go2.arena
        elsif Group.leader?
          "arena:team".go2
        end

        if Group.leader? or Group.empty?
          Interactive.capture("please ;send ok to begin", /^ok$/)
        end
      end
    end
  end
end