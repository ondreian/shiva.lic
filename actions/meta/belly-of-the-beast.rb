=begin
  You catch one last glimpse of your surroundings as darkness closes in on you...
[The Belly of the Beast - ] (u113001)
You notice the crawler's stomach wall.
Obvious exits: none
=end

module Shiva
  class BellyOfTheBeast < Action
    def priority
      -1000
    end

    def available?
      XMLData.room_id.eql? 113001
    end

    def find_dagger
      dagger = Containers.harness.find {|item| Tactic::Nouns::Dagger.include?(item.noun) }
      fail "todo: handle this!!! you're gonna die"
      dagger.take
      return dagger
      #fput "swap" if Tactic::Nouns::Dagger.include?(Char.left)
    end

    def apply
      Char.unarm
      dagger = self.find_dagger
      while XMLData.room_id.eql?(113001)
        fput "attack wall" if Tactic.dagger?
        sleep 0.1
        waitrt?
      end
      Containers.harness.add(dagger)
      Char.arm
    end
  end
end