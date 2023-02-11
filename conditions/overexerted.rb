module Shiva
  module Conditions
    module Overexerted
      def self.handle!
        return unless Effects::Debuffs.active?("Overexerted")
        wait_while("waiting on exertion") {Effects::Debuffs.active?("Overexerted")}
      end
    end
  end
end