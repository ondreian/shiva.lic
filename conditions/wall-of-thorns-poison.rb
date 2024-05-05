# Wall of Thorns Poison 3
module Shiva
  module Conditions
    module WallOfThorns
      def self.status
        Effects::Debuffs.to_h.keys.map(&:to_s)
          .find {|k| k.start_with? "Wall of Thorns Poison"}.split(" ").pop.to_i
      end

      def self.handle!
        wait_while("waiting on wall of thorns") {self.status > 2}
      end
    end
  end
end