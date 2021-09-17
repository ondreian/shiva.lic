require_relative "../../stage"

module Shiva
  module Duskruin
    class Setup < Stage
      def find_pass_book
        Containers.harness.where(noun: "booklet").first or
        #Containers.harness.where(noun: "pass").first or
        Containers.harness.where(noun: "voucher").first or
        fail "no booklets"
      end

      def use_booklet
        empty_hands
        booklet = self.find_pass_book
        booklet.take
        fput "go entrance" if Group.leader? or Group.empty?
        wait_until {Duskruin::Rooms.combat.include?(Room.current.id)}
        Containers.harness.add(booklet) if Char.right.id.eql?(booklet.id)
      end

      def enter_arena
        self.use_booklet
      end

      def shout
        while line=get
          break if line.start_with?(%[An announcer shouts])
        end
        put "shout" # it out
        wait_while {Foes.empty?}
      end

      def reset
        :noop
      end

      def apply(env)
        return if Duskruin::Rooms.combat.include?(Room.current.id)
        Group.check
        Support.small_statue if Char.spell(1712).minutes < 8
        Support.pure_potion if Char.spell(211).minutes < 8
        Spell[1035].cast if Spell[1035].known?
        self.enter_arena
        Char.arm
        Script.start("lte")
        Script.start("reaction")
        self.shout if Duskruin::Rooms.combat.include?(Room.current.id) and Group.empty?
      end
    end
  end
end