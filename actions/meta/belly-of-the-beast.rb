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

    def apply
      fput "swap" if Tactic::Nouns::Dagger.include?(Char.left)
      fput "attack wall" if Tactic.dagger?
    end
  end
end