module Shiva
  module Conditions
    module Burrowed
      def self.handle!
        return unless Effects::Debuffs.active?("Burrowed")
        wait_while("waiting on burrowed...") {Effects::Debuffs.active?("Burrowed")}
      end
    end
  end
end